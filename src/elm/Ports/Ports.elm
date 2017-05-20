port module Ports.Ports exposing (..)

import Model.Model exposing (..)


port newEvent : (Event -> msg) -> Sub msg


port addEvent : Event -> Cmd msg


port editEvent : Event -> Cmd msg


port removeEvent : Event -> Cmd msg


port eventSaved : (String -> msg) -> Sub msg


port toggleSignIn : String -> Cmd msg


port signIn : (User -> msg) -> Sub msg


port signOut : (String -> msg) -> Sub msg
