module Subscriptions.Subscriptions exposing (subscriptions)

import Model.Model exposing (..)
import Update.Update exposing (..)
import Ports.Ports exposing (..)


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ newEvent EventAdded
        , eventSaved EventSaved
        , signIn SignIn
        , signOut SignOut
        ]
