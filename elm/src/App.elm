port module App exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Material
import Material.Scheme
import Material.Options as Options
import Material.Elevation as Elevation
import List
import Json.Encode as Json


main =
    Html.program { init = init, subscriptions = subscriptions, view = view, update = update }



-- MODEL


type alias Model =
    { synopticoSet : Maybe SynopticoSet
    , mdl : Material.Model
    }


type alias SynopticoSet =
    { webviews : List WebView
    , name : String
    }


type alias WebView =
    { url : String
    , position : ScreenPosition
    }


type alias ScreenPosition =
    { top : String
    , left : String
    , height : String
    , width : String
    , zIndex : String
    }


init : ( Model, Cmd Msg )
init =
    ( { synopticoSet = Nothing
      , mdl = Material.model
      }
    , Cmd.none
    )



-- PORTS


port openSynopticoSet : (Maybe SynopticoSet -> msg) -> Sub msg



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    openSynopticoSet OpenSynopticoSet



-- UPDATE


type Msg
    = Mdl (Material.Msg Msg)
    | OpenSynopticoSet (Maybe SynopticoSet)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Mdl msg_ ->
            Material.update Mdl msg_ model

        OpenSynopticoSet synopticoSet ->
            ( { model | synopticoSet = synopticoSet }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ viewSynopticoSet model.synopticoSet ]


viewSynopticoSet : Maybe SynopticoSet -> Html Msg
viewSynopticoSet synopticoSet =
    case synopticoSet of
        Just synopticoSet ->
            div [ style [ ( "display", "flex" ) ] ] (List.map webview synopticoSet.webviews)

        Nothing ->
            div [] []


webview { url, position } =
    Options.div
        [ Elevation.e24
        , Options.css "position" "absolute"
        , Options.css "top" position.top
        , Options.css "left" position.left
        , Options.css "width" position.width
        , Options.css "height" position.height
        , Options.css "z-index" position.zIndex
        ]
        [ node "webview"
            [ src url
            , style [ ( "height", "100%" ), ( "width", "100%" ) ]
            , Html.Attributes.property "allowpopups" (Json.bool True)
            ]
            []
        ]
