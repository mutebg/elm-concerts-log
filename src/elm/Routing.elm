module Routing exposing (..)

import Navigation exposing (Location)
import Model.Model exposing (Msg, Msg(..), Page, Page(..))
import UrlParser exposing (..)


matchers : Parser (Page -> a) a
matchers =
    oneOf
        [ map Home top
        , map Details (s "details" </> string)
        , map LogIn (s "login")
        , map Home (s "home")
        ]


parseLocation : Location -> Page
parseLocation location =
    case (parseHash matchers location) of
        Just page ->
            page

        Nothing ->
            NotFound
