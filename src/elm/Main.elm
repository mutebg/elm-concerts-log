port module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Array
import Time
import Process
import Task


-- component import example
-- import Components.Hello exposing ( hello )
-- TYPES


type alias Event =
    { id : String
    , imgUrl : String
    , location : String
    , name : String
    , place : String
    , color : String
    , datetime : String
    }


type FormActions
    = Add
    | Edit
    | None


port newEvent : (Event -> msg) -> Sub msg


port addEvent : Event -> Cmd msg


port editEvent : Event -> Cmd msg


port removeEvent : Event -> Cmd msg


port eventSaved : (String -> msg) -> Sub msg



-- APP


main : Program Never Model Msg
main =
    Html.program { init = init, view = view, update = update, subscriptions = subscriptions }



-- MODEL


type alias Model =
    { events : List Event
    , selected : Int
    , next : Int
    , inTransition : Bool
    , openNav : Bool
    , showForm : FormActions
    , currentEvent : Event
    }


initModel : Model
initModel =
    { selected = 0
    , next = 1
    , inTransition = False
    , events = []
    , openNav = False
    , showForm = None
    , currentEvent = emptyEvent
    }


init : ( Model, Cmd Msg )
init =
    ( initModel, Cmd.none )



-- SUBSCRIBTION


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ newEvent EventAdded
        , eventSaved EventSaved
        ]



-- UPDATE


type Msg
    = NoOp
    | ToggleNav
    | MoveTo Int
    | TransitionTo Int
    | EventAdded Event
    | AddEventForm
    | CloseEventForm
    | UpdateEvenInput String String
    | SaveAddEvent
    | EventSaved String
    | EditEventForm Event
    | SaveEditForm
    | DeleteEvent Event


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

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



-- VIEW
-- Html is defined as: elem [ attribs ][ children ]
-- CSS can be applied via class names or inline style attrib


view : Model -> Html Msg
view model =
    div
        [ class
            (if model.openNav then
                "main main--with-nav"
             else
                "main"
            )
        ]
        [ printNav model
        , button [ class "nav-btn", onClick ToggleNav ] []
        , button [ class "btn btn--prev", disabled model.inTransition, onClick (TransitionTo (model.selected - 1)) ] []
        , printEvents model
        , button [ class "btn btn--next", disabled model.inTransition, onClick (TransitionTo (model.selected + 1)) ] []
        , a [ href "https://github.com/mutebg/elm-concerts-log", class "copy" ] [ text "source code" ]
        , printEventPopup model
        ]


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



-- getEvent : Model -> Maybe Event
-- getEvent model =
--     Array.get model.selected <| Array.fromList model.events


printEvents : Model -> Html Msg
printEvents model =
    let
        curryPrintEvent =
            printEvent model.selected model.next model.inTransition
    in
        div [ class "events" ]
            (List.indexedMap curryPrintEvent model.events)


printEvent : Int -> Int -> Bool -> Int -> Event -> Html Msg
printEvent selected next inTransition index event =
    let
        zIndex =
            if selected == index then
                "30"
            else if next == index && inTransition then
                "20"
            else
                "0"

        transitionClass =
            if inTransition && selected == index then
                "event event--hide"
            else
                "event"
    in
        div
            [ class transitionClass
            , style
                [ ( "background-image", "url(" ++ event.imgUrl ++ ")" )
                , ( "background-color", event.color )
                , ( "z-index", zIndex )
                ]
            ]
            [ div [ class "event__box" ]
                [ h1 [ class "event__title" ] [ text event.name ]
                , p [ class "event__date" ] [ text event.datetime ]
                , p [ class "event__place" ] [ text (event.place ++ ", " ++ event.location) ]
                , p [ class "event__edit" ]
                    [ button [ onClick (EditEventForm event) ] [ text "Edit" ]
                    , button [ onClick (DeleteEvent event) ] [ text "Delete" ]
                    ]
                ]
            ]


printNav : Model -> Html Msg
printNav model =
    div [ class "nav nav--show" ]
        [ button [ onClick AddEventForm ] [ text "Add Event" ]
        , ul
            []
            (List.indexedMap
                (\index event ->
                    li [ onClick (TransitionTo index) ]
                        [ span [ class "large" ] [ text event.name ]
                        , span [ class "small" ]
                            [ text (event.datetime ++ " " ++ event.place) ]
                        ]
                )
                model.events
            )
        ]


printEventPopup : Model -> Html Msg
printEventPopup model =
    case model.showForm of
        Add ->
            div [ class "popup" ] [ printEventForm model.currentEvent "Add Event" SaveAddEvent ]

        Edit ->
            div [ class "popup" ] [ printEventForm model.currentEvent "Edit Event" SaveEditForm ]

        None ->
            div [ class "popup popup--hiden" ] []


printEventForm : Event -> String -> Msg -> Html Msg
printEventForm event title action =
    div [ class "popup__box" ]
        [ h1 [ class "popup__title" ] [ text title ]
        , button [ class "popup__close", onClick CloseEventForm ] [ text "" ]
        , input [ class "popup__input", type_ "text", placeholder "Name", value event.name, onInput (UpdateEvenInput "name") ] []
        , input [ class "popup__input", type_ "text", placeholder "Place", value event.place, onInput (UpdateEvenInput "place") ] []
        , input [ class "popup__input", type_ "text", placeholder "Location", value event.location, onInput (UpdateEvenInput "location") ] []
        , input [ class "popup__input", type_ "datetime-local", placeholder "Date/Time", value event.datetime, onInput (UpdateEvenInput "datetime") ] []
        , input [ class "popup__input", type_ "url", placeholder "Image", value event.imgUrl, onInput (UpdateEvenInput "imgUrl") ] []
        , button [ class "popup__submit", onClick action ] [ text "Save " ]
        ]


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


emptyEvent : Event
emptyEvent =
    { id = ""
    , imgUrl = ""
    , location = ""
    , name = ""
    , place = ""
    , color = "red"
    , datetime = ""
    }
