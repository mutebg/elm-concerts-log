module Model.Model exposing (..)

import Http


type Page
    = Home
    | Details String
    | LogIn
    | NotFound


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


type alias User =
    { name : String
    , avatar : String
    }


type alias Model =
    { events : List Event
    , selected : Int
    , next : Int
    , inTransition : Bool
    , openNav : Bool
    , showForm : FormActions
    , currentEvent : Event
    , user : Maybe User
    , page : Page
    }


type Msg
    = NoOp
    | ToggleSignIn
    | SignIn User
    | SignOut String
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
    | FetchImage
    | NewImage (Result Http.Error String)
    | Navigate Page
    | ChangePage Page


initModel : Model
initModel =
    { selected = 0
    , next = 1
    , inTransition = False
    , events = []
    , openNav = False
    , showForm = None
    , currentEvent = emptyEvent
    , user = Nothing
    , page = Home
    }


init : ( Model, Cmd Msg )
init =
    ( initModel, Cmd.none )


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
