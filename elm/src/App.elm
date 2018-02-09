port module App exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Svg as S
import Svg.Attributes as SA
import List
import Dict
import Json.Encode as Json
import Time exposing (Time, second)
import Maybe exposing (withDefault)
import Array
import Json.Decode as Decode
import Json.Decode.Pipeline as DecodeP


main =
    Html.programWithFlags { init = init, subscriptions = subscriptions, view = view, update = update }



-- MODEL


type alias Model =
    { synopticoSet : Maybe SynopticoSet
    , platform : Platform
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


type Platform
    = Darwin
    | Other


type alias Flags =
    { platform : String }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { synopticoSet = Nothing
      , platform = toPlatform flags.platform
      }
    , Cmd.none
    )


toPlatform : String -> Platform
toPlatform platform =
    case platform of
        "darwin" ->
            Darwin

        _ ->
            Other



-- PORTS


port openSynopticoSet : (Decode.Value -> msg) -> Sub msg


port error : String -> Cmd msg


port openFile : () -> Cmd msg



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
    | OpenFile
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

        OpenFile ->
            ( model, openFile () )

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
        [ viewSynopticoSet model.synopticoSet model.platform ]


viewSynopticoSet : Maybe SynopticoSet -> Platform -> Html Msg
viewSynopticoSet synopticoSet platform =
    case synopticoSet of
        Just synopticoSet ->
            div [ class "flex" ] (List.map webview synopticoSet.webviews)

        Nothing ->
            div [] [ home (modifierIcon platform) ]

webview : WebView -> Html msg
webview { urls, position } =
    div
        [ class "bg-washed-blue shadow-4"
        , style
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

modifierIcon : Platform -> Html msg
modifierIcon platform =
    case platform of
        Darwin ->
            S.svg [ SA.width "24", SA.height "24", SA.viewBox "0 0 24 24", SA.fill "none", SA.stroke "currentColor", SA.strokeWidth "2", SA.strokeLinecap "round", SA.strokeLinejoin "round", SA.class "feather feather-command white self-center", SA.color "#384047" ]
                [ S.path [ SA.d "M18 3a3 3 0 0 0-3 3v12a3 3 0 0 0 3 3 3 3 0 0 0 3-3 3 3 0 0 0-3-3H6a3 3 0 0 0-3 3 3 3 0 0 0 3 3 3 3 0 0 0 3-3V6a3 3 0 0 0-3-3 3 3 0 0 0-3 3 3 3 0 0 0 3 3h12a3 3 0 0 0 3-3 3 3 0 0 0-3-3z" ]
                    []
                ]

        Other ->
            S.svg [ SA.width "24", SA.height "24", SA.viewBox "0 0 24 24", SA.fill "none", SA.stroke "currentColor", SA.strokeWidth "2", SA.strokeLinecap "round", SA.strokeLinejoin "round", SA.class "feather feather-chevron-up white", SA.color "#384047" ]
                [ S.polyline [ SA.points "18 15 12 9 6 15" ]
                    []
                ]

home : Html Msg -> Html Msg
home modifierIcon =
    div [ class "absolute w-100 h-100 tc flex flex-column items-center justify-center sans-serif black-10 bg-washed-blue" ]
        [ div [ class "f2 fw6 lh-title pa2" ]
            [ text "Drag & drop a Synoptico dashboard file here" ]
        , div [ class "f3 lh-copy pa1 pa2" ]
            [ span [ class "pr1" ]
                [ text "Or press " ]
            , a [ onClick OpenFile, class "pa2 bg-black-40 hover-bg-black-50 pointer bg-animate shadow-4 br2 white inline-flex" ]
                [ span [ class "pr2" ]
                    [ text "Open" ]
                , modifierIcon
                , span [ class "" ]
                    [ text "O" ]
                ]
            ]
        ]
