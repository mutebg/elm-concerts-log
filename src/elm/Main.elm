module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import GraphQL.Request.Builder exposing (..)
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var
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
    }



-- FAKE DATA


radiohead : Event
radiohead =
    { id = "2", imgUrl = "2.jpg", location = "Drente", name = "Radiohead", place = "Rose", color = "red" }


muse : Event
muse =
    { id = "1", imgUrl = "1.jpg", location = "Amsterdam", name = "Muse", place = "Ziggo", color = "blue" }


rhcp : Event
rhcp =
    { id = "3", imgUrl = "3.jpg", location = "Amsterdam", name = "RHCP", place = "Ziggo", color = "pink" }



-- APP


main : Program Never Model Msg
main =
    Html.beginnerProgram { model = model, view = view, update = update }



-- MODEL


type alias Model =
    { events : List Event
    , selected : Int
    }


model : Model
model =
    { selected = 0
    , events =
        []
        -- rhcp, muse, radiohead ]
    }



-- UPDATE


type Msg
    = NoOp
    | MoveForward
    | MoveBack


update : Msg -> Model -> Model
update msg model =
    case msg of
        NoOp ->
            model

        MoveForward ->
            moveForward model

        MoveBack ->
            moveBack model



-- VIEW
-- Html is defined as: elem [ attribs ][ children ]
-- CSS can be applied via class names or inline style attrib


view : Model -> Html Msg
view model =
    div []
        [ button [ class "btn btn--prev", onClick MoveBack ] [ text "Back " ]
        , div [] [ printEvent <| getEvent model ]
        , button [ class "btn btn--next", onClick MoveForward ] [ text "Forward " ]
        ]


moveForward : Model -> Model
moveForward model =
    if List.length model.events - 1 == model.selected then
        { model | selected = 0 }
    else
        { model | selected = model.selected + 1 }


moveBack : Model -> Model
moveBack model =
    if model.selected == 0 then
        { model | selected = List.length model.events - 1 }
    else
        { model | selected = model.selected - 1 }


getEvent : Model -> Maybe Event
getEvent model =
    Array.get model.selected <| Array.fromList model.events


printEvent : Maybe Event -> Html Msg
printEvent event =
    case event of
        Nothing ->
            div [ class "error" ] [ text "NO SUCH A EVENT" ]

        Just event ->
            div [ class "event" ]
                [ h1 [ class "event__title" ] [ text event.name ]
                , p [ class "event__place" ] [ text event.place ]
                , p [ class "event__location" ] [ text event.location ]
                ]
