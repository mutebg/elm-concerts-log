port module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Array


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



-- Ports : Outgoing
-- Ports: Incoming


port newEvent : (Event -> msg) -> Sub msg



-- FAKE DATA


radiohead : Event
radiohead =
    { id = "2", datetime = "20.12.2016", location = "London", name = "Radiohead", place = "O2", color = "red", imgUrl = "https://lastfm-img2.akamaized.net/i/u/770x0/598ae6dc5674923861236cca00e1eb84.jpg" }


muse : Event
muse =
    { id = "1", datetime = "20.11.2016", location = "Amsterdam", name = "Muse", place = "Ziggo", color = "blue", imgUrl = "https://lastfm-img2.akamaized.net/i/u/770x0/2cf19f323f4c704a8a2a234a0e72988e.jpg" }


lcd : Event
lcd =
    { id = "3", datetime = "20.10.2016", location = "Amsterdam", name = "LCD Soundsystem", place = "Ziggo", color = "pink", imgUrl = "https://lastfm-img2.akamaized.net/i/u/770x0/e2f3e6d6f22d4b76ab3460d95d11dc92.jpg" }



-- APP


main : Program Never Model Msg
main =
    Html.program { init = init, view = view, update = update, subscriptions = subscriptions }



-- MODEL


type alias Model =
    { events : List Event
    , selected : Int
    , openNav : Bool
    }


initModel : Model
initModel =
    { selected = 0
    , events = []
    , openNav = False
    }


init : ( Model, Cmd Msg )
init =
    ( initModel, Cmd.none )



-- SUBSCRIBTION


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ newEvent EventAdded
        ]



-- UPDATE


type Msg
    = NoOp
    | ToggleNav
    | MoveTo Int
    | EventAdded Event


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        ToggleNav ->
            ( toggleNav model, Cmd.none )

        MoveTo newSelected ->
            ( moveTo newSelected model, Cmd.none )

        EventAdded event ->
            let
                newEvents =
                    event :: model.events
            in
                ( { model | events = newEvents }, Cmd.none )



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
        , button [ class "nav-btn", onClick ToggleNav ] [ text "nav" ]
        , button [ class "btn btn--prev", onClick (MoveTo (model.selected - 1)) ] [ text "<" ]
        , div [] [ printEvent <| getEvent model ]
        , button [ class "btn btn--next", onClick (MoveTo (model.selected + 1)) ] [ text ">" ]
        ]


moveTo : Int -> Model -> Model
moveTo index model =
    if index >= 0 && index < List.length model.events then
        { model | selected = index }
    else if 0 > index then
        { model | selected = List.length model.events - 1 }
    else
        { model | selected = 0 }


toggleNav : Model -> Model
toggleNav model =
    { model | openNav = not model.openNav }


getEvent : Model -> Maybe Event
getEvent model =
    Array.get model.selected <| Array.fromList model.events


printEvent : Maybe Event -> Html Msg
printEvent event =
    case event of
        Nothing ->
            div [ class "error" ] [ text "NO SUCH A EVENT" ]

        Just event ->
            div [ class ("event filter-" ++ event.color), style [ ( "background-image", "url(" ++ event.imgUrl ++ ")" ) ] ]
                [ div [ class "event__box" ]
                    [ h1 [ class "event__title" ] [ text event.name ]
                    , p [ class "event__date" ] [ text event.datetime ]
                    , p [ class "event__place" ] [ text (event.place ++ ", " ++ event.location) ]
                    ]
                ]


printNav : Model -> Html Msg
printNav model =
    div [ class "nav nav--show" ]
        [ ul []
            (List.indexedMap
                (\index event -> li [ onClick (MoveTo index) ] [ text event.name ])
                model.events
            )
        ]
