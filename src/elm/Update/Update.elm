module Update.Update exposing (..)

import Model.Model exposing (..)
import Array
import Process
import Task
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, required)
import Http
import Time
import Ports.Ports exposing (..)
import Routing exposing (parseLocation)
import RemoteData


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        OnLocationChange location ->
            let
                newRoute =
                    parseLocation location

                cmd =
                    pageToCmd model newRoute
            in
                ( { model | page = newRoute }, cmd )

        ToggleSignIn ->
            ( model, toggleSignIn "none" )

        SignIn newUser ->
            ( { model | user = Just newUser }, Cmd.none )

        SignOut none ->
            ( { model | user = Nothing }, Cmd.none )

        ToggleNav ->
            ( { model | openNav = not model.openNav }, Cmd.none )

        MoveTo newSelected ->
            ( { model | selected = moveTo newSelected model, inTransition = False }, Cmd.none )

        TransitionTo newSelected ->
            ( { model | inTransition = True, next = moveTo newSelected model }, delay 1200 (MoveTo newSelected) )

        EventAdded event ->
            let
                newEvents =
                    event :: model.events
            in
                ( { model | events = newEvents }, Cmd.none )

        AddEventForm ->
            ( { model | showForm = Add, openNav = False }, Cmd.none )

        CloseEventForm ->
            ( { model | showForm = None }, Cmd.none )

        UpdateEvenInput inputName inputValue ->
            ( updateFormInputs model inputName inputValue, Cmd.none )

        SaveAddEvent ->
            ( model, addEvent model.currentEvent )

        EventSaved key ->
            ( { model | currentEvent = emptyEvent, showForm = None }, Cmd.none )

        EditEventForm event ->
            ( { model | currentEvent = event, showForm = Edit }, Cmd.none )

        SaveEditForm ->
            ( updateEventInList model, editEvent model.currentEvent )

        DeleteEvent event ->
            ( deleteEventInList model event, removeEvent event )

        FetchImage ->
            ( model, fetchImage model.currentEvent.name )

        NewImage (Ok imgUrl) ->
            ( updateFormInputs model "imgUrl" imgUrl, Cmd.none )

        NewImage (Err _) ->
            ( updateFormInputs model "imgUrl" "http://kingofwallpapers.com/band/band-006.jpg", Cmd.none )

        FetchEventDetails ->
            ( model, Cmd.none )

        OnFetchSetlist response ->
            ( { model | setlist = response }, Cmd.none )


updateFormInputs : Model -> String -> String -> Model
updateFormInputs model inputName inputValue =
    let
        oldCurrentEvent =
            model.currentEvent

        newCurrentEvent =
            case inputName of
                "name" ->
                    { oldCurrentEvent | name = inputValue }

                "place" ->
                    { oldCurrentEvent | place = inputValue }

                "location" ->
                    { oldCurrentEvent | location = inputValue }

                "datetime" ->
                    { oldCurrentEvent | datetime = inputValue }

                "imgUrl" ->
                    { oldCurrentEvent | imgUrl = inputValue }

                _ ->
                    oldCurrentEvent
    in
        { model | currentEvent = newCurrentEvent }


updateEventInList : Model -> Model
updateEventInList model =
    let
        newEvents =
            Array.toList <| Array.set model.selected model.currentEvent <| Array.fromList model.events
    in
        { model | events = newEvents }


deleteEventInList : Model -> Event -> Model
deleteEventInList model event =
    let
        newEvents =
            List.filter (\e -> e.id /= event.id) model.events
    in
        { model | events = newEvents }


fetchImage : String -> Cmd Msg
fetchImage artist =
    let
        url =
            "https://api.spotify.com/v1/search?type=artist&q=" ++ artist

        request =
            Http.get url decodeImgUrl
    in
        Http.send NewImage request


decodeImgUrl : Decode.Decoder String
decodeImgUrl =
    Decode.at [ "artists", "items", "0", "images", "0", "url" ] Decode.string


fetchEventDetails : Event -> Cmd Msg
fetchEventDetails event =
    let
        url =
            "http://api.setlist.fm/rest/0.1/search/setlists.json?artistName=" ++ event.name
    in
        Http.get url decodeSetlist
            |> RemoteData.sendRequest
            |> Cmd.map OnFetchSetlist


decodeSetlist : Decode.Decoder (List String)
decodeSetlist =
    --Decode.at [ "setlists", "setlist", "0", "sets", "set", "song" ] Decode.list (decodeSetlistItem)
    Decode.list (decodeSetlistItem)


decodeSetlistItem : Decode.Decoder String
decodeSetlistItem =
    Decode.at [ "setlists", "setlist", "0", "sets", "set", "song", "@name" ] Decode.string


moveTo : Int -> Model -> Int
moveTo index model =
    if index >= 0 && index < List.length model.events then
        index
    else if 0 > index then
        List.length model.events - 1
    else
        0


delay : Time.Time -> msg -> Cmd msg
delay time msg =
    Process.sleep time
        |> Task.andThen (always <| Task.succeed msg)
        |> Task.perform identity


pageToHash : Page -> String
pageToHash page =
    case page of
        Home ->
            "#"

        Details id ->
            "#details/" ++ id

        LogIn ->
            "#login"

        NotFound ->
            "#notfound"


getEventByID : String -> List Event -> Maybe Event
getEventByID id events =
    List.head <|
        List.filter (\e -> e.id == id) events


pageToCmd : Model -> Page -> Cmd Msg
pageToCmd model page =
    case page of
        Details id ->
            case getEventByID id model.events of
                Just event ->
                    fetchEventDetails event

                _ ->
                    Cmd.none

        _ ->
            Cmd.none
