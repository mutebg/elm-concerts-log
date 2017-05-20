module View.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onBlur)
import Model.Model exposing (..)


-- VIEW


view : Model -> Html Msg
view model =
    case model.user of
        Just user ->
            logedUserPage model

        Nothing ->
            unLogedUserpage model


logedUserPage : Model -> Html Msg
logedUserPage model =
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


unLogedUserpage : Model -> Html Msg
unLogedUserpage model =
    div [ class "main unloged" ]
        [ h1 [] [ text "Log in with your Google Account to access your profile" ]
        , showLoginButton model
        ]


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
        , showLogOutButton model
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
        , input [ class "popup__input", type_ "text", placeholder "Name", value event.name, onInput (UpdateEvenInput "name"), onBlur FetchImage ] []
        , img [ class "popup__img", src event.imgUrl ] []
        , input [ class "popup__input", type_ "text", placeholder "Place", value event.place, onInput (UpdateEvenInput "place") ] []
        , input [ class "popup__input", type_ "text", placeholder "Location", value event.location, onInput (UpdateEvenInput "location") ] []
        , input [ class "popup__input", type_ "datetime-local", placeholder "Date/Time", value event.datetime, onInput (UpdateEvenInput "datetime") ] []
          --, input [ class "popup__input", type_ "url", placeholder "Image", value event.imgUrl, onInput (UpdateEvenInput "imgUrl") ] []
        , button [ class "popup__submit", onClick action ] [ text "Save " ]
        ]


showLoginButton : Model -> Html Msg
showLoginButton model =
    case model.user of
        Nothing ->
            button [ onClick ToggleSignIn ] [ text "Login with Google Account" ]

        _ ->
            Html.text ""


showLogOutButton : Model -> Html Msg
showLogOutButton model =
    case model.user of
        Just user ->
            button [ class "btn", onClick ToggleSignIn ] [ text <| "Logout " ++ user.name ]

        _ ->
            Html.text ""
