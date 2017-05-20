module Main exposing (..)

import Html
import Subscriptions.Subscriptions exposing (subscriptions)
import Update.Update exposing (update)
import View.View exposing (view)
import Model.Model exposing (init, Model, Msg)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
