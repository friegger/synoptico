port module App exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Material
import Material.Scheme
import Material.Options as Options
import Material.Elevation as Elevation
import List
import Dict
import Json.Encode as Json
import Time exposing (Time, second)
import Maybe exposing (withDefault)
import Array


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
    { urls : List String
    , position : ScreenPosition
    , timer : Maybe Int
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
    let
        webviews =
            case model.synopticoSet of
                Just set ->
                    set.webviews

                Nothing ->
                    []
    in
        Sub.batch
            [ openSynopticoSet OpenSynopticoSet
            , Sub.batch (List.indexedMap createTimer webviews)
            ]


createTimer : Int -> WebView -> Sub Msg
createTimer index webview =
    case webview.timer of
        Just timer ->
            Time.every ((toFloat timer) * second) (\_ -> RotateWebViewUrl index)

        Nothing ->
            Sub.none



-- UPDATE


type Msg
    = Mdl (Material.Msg Msg)
    | OpenSynopticoSet (Maybe SynopticoSet)
    | RotateWebViewUrl Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Mdl msg_ ->
            Material.update Mdl msg_ model

        OpenSynopticoSet synopticoSet ->
            ( { model | synopticoSet = synopticoSet }, Cmd.none )

        RotateWebViewUrl webviewIndex ->
            ( { model | synopticoSet = rotateUrlOf model.synopticoSet webviewIndex }, Cmd.none )


rotateUrlOf set webviewIndex =
    case set of
        Just set ->
            Just { set | webviews = rotateUrl webviewIndex set.webviews }

        Nothing ->
            Nothing


rotateUrl webviewIndex =
    List.indexedMap
        (\index webview ->
            if webviewIndex == index then
                { webview | urls = shift webview.urls }
            else
                webview
        )


shift : List a -> List a
shift list =
    case list of
        head :: tail ->
            List.append tail [ head ]

        [] ->
            []



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


webview { urls, position } =
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
            [ src <| withDefault "" <| List.head urls
            , style [ ( "height", "100%" ), ( "width", "100%" ) ]
            , Html.Attributes.property "allowpopups" (Json.bool True)
            ]
            []
        ]
