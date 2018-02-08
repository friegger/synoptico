port module App exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import List
import Dict
import Json.Encode as Json
import Time exposing (Time, second)
import Maybe exposing (withDefault)
import Array
import Json.Decode as Decode
import Json.Decode.Pipeline as DecodeP


main =
    Html.program { init = init, subscriptions = subscriptions, view = view, update = update }



-- MODEL


type alias Model =
    { synopticoSet : Maybe SynopticoSet
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
    ( { synopticoSet = Nothing }
    , Cmd.none
    )



-- PORTS


port openSynopticoSet : (Decode.Value -> msg) -> Sub msg


port error : String -> Cmd msg



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
            [ openSynopticoSet (Decode.decodeValue (Decode.nullable synopticoSetDecoder) >> OpenSynopticoSet)
            , Sub.batch (List.indexedMap createTimer webviews)
            ]


createTimer : Int -> WebView -> Sub Msg
createTimer index webview =
    case webview.timer of
        Just timer ->
            Time.every ((toFloat timer) * second) (\_ -> RotateWebViewUrl index)

        Nothing ->
            Sub.none


synopticoSetDecoder =
    DecodeP.decode SynopticoSet
        |> DecodeP.required "webviews" (Decode.list webViewDecoder)
        |> DecodeP.required "name" Decode.string


webViewDecoder =
    DecodeP.decode WebView
        |> DecodeP.required "urls" (Decode.list Decode.string)
        |> DecodeP.required "position" screenPositionDecoder
        |> DecodeP.optional "timer" (Decode.nullable Decode.int) Nothing


screenPositionDecoder =
    DecodeP.decode ScreenPosition
        |> DecodeP.required "top" Decode.string
        |> DecodeP.required "left" Decode.string
        |> DecodeP.required "height" Decode.string
        |> DecodeP.required "width" Decode.string
        |> DecodeP.required "zIndex" Decode.string



-- UPDATE


type Msg
    = OpenSynopticoSet (Result String (Maybe SynopticoSet))
    | RotateWebViewUrl Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OpenSynopticoSet synopticoSetResult ->
            case synopticoSetResult of
                Ok synopticoSet ->
                    ( { model | synopticoSet = synopticoSet }, Cmd.none )

                Err errorMsg ->
                    ( { model | synopticoSet = Nothing }, error errorMsg )

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
    Html.div
        [ Html.Attributes.style
            [ ( "position", "absolute" )
            , ( "top", position.top )
            , ( "left", position.left )
            , ( "width", position.width )
            , ( "height", position.height )
            , ( "z-index", position.zIndex )
            ]
        ]
        [ node "webview"
            [ src <| withDefault "" <| List.head urls
            , style [ ( "height", "100%" ), ( "width", "100%" ) ]
            , Html.Attributes.property "allowpopups" (Json.bool True)
            ]
            []
        ]
