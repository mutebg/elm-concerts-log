module Main exposing (..)

import Subscriptions.Subscriptions exposing (subscriptions)
import Update.Update exposing (update)
import View.View exposing (view)
import Model.Model exposing (init, Model, Msg)
import Navigation exposing (Location)


initFn : Location -> ( Model, Cmd Msg )
initFn location =
    init


main : Program Never Model Msg
main =
    Navigation.program Model.Model.OnLocationChange
        { init = initFn
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
