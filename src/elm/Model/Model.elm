module Model.Model exposing (..)

import Http
import Navigation exposing (Location)
import RemoteData exposing (WebData)


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
    , setlist : WebData (List String)
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
    | OnLocationChange Location
    | FetchEventDetails
    | OnFetchSetlist (WebData (List String))


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
    , setlist = RemoteData.NotAsked
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
