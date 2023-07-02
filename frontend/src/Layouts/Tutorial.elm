module Layouts.Tutorial exposing (Model, Msg, Props, layout)

import Browser.Events as BE
import Debug
import Effect exposing (Effect)
import Html exposing (Html, button, div, footer, header, iframe, progress, text)
import Html.Attributes exposing (class, src, step, style, width)
import Html.Events as HE
import Json.Decode as Decode
import Layout exposing (Layout)
import Route exposing (Route)
import Shared
import Utils.JsonParser.Scenario exposing (Step)
import View exposing (View)


type alias Props =
    { step : Int
    , totalSteps : Int
    }


layout : Props -> Shared.Model -> Route () -> Layout () Model Msg contentMsg
layout props shared route =
    Layout.new
        { init = init shared
        , update = update
        , view = view props
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { resizeState : ResizeState
    , screenWidth : Float
    }


type ResizeState
    = Resizing Float
    | NotResizing Float


init : Shared.Model -> () -> ( Model, Effect Msg )
init shared _ =
    ( { resizeState = NotResizing (0.5 * shared.screenWidth)
      , screenWidth = shared.screenWidth
      }
    , Effect.none
    )



-- UPDATE


type Msg
    = ResizeStart
    | ResizeInProgress Bool Float
    | ResizeStop Float


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ResizeStart ->
            ( { model | resizeState = Resizing (toFraction model.resizeState) }
            , Effect.none
            )

        ResizeInProgress isDown fraction ->
            ( { model
                | resizeState =
                    if isDown then
                        Resizing fraction

                    else
                        NotResizing <| toFraction model.resizeState
              }
            , Effect.none
            )

        ResizeStop fraction ->
            ( { model | resizeState = NotResizing fraction }
            , Effect.none
            )


toFraction : ResizeState -> Float
toFraction resizeState =
    case resizeState of
        Resizing fraction ->
            fraction

        NotResizing fraction ->
            fraction



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.resizeState of
        Resizing _ ->
            Sub.batch
                [ BE.onMouseMove <| Decode.map2 ResizeInProgress decodeButton <| Decode.field "pageX" Decode.float
                , BE.onMouseUp <| Decode.map ResizeStop <| Decode.field "pageX" Decode.float
                ]

        NotResizing _ ->
            Sub.none


decodeButton : Decode.Decoder Bool
decodeButton =
    Decode.field "buttons" (Decode.map (\buttons -> buttons == 1) Decode.int)



-- VIEW


view : Props -> { toContentMsg : Msg -> contentMsg, content : View contentMsg, model : Model } -> View contentMsg
view props { toContentMsg, model, content } =
    { title = content.title
    , body =
        [ div [ class containerClass ]
            [ viewHeader model content
            , div [ class paneContainerClass ]
                [ viewContentPane model content
                , viewResizer model |> Html.map toContentMsg
                , viewTerminalPane model |> Html.map toContentMsg
                ]
            , viewFooter props |> Html.map toContentMsg
            ]
        ]
    }


toPointerEvent : ResizeState -> String
toPointerEvent resizeState =
    case resizeState of
        Resizing _ ->
            "none"

        NotResizing _ ->
            "auto"



-- TailwindCSS classes for basic styling


headerClass =
    "bg-rose-800 text-white px-4 flex items-center sticky top-0 z-10 py-6"


footerClass =
    "bg-rose-800 text-white p-4 flex items-center sticky bottom-0 z-10"


containerClass =
    "flex flex-col h-screen w-full overflow-hidden"


paneContainerClass =
    "flex flex-col md:flex-row flex-grow h-full w-full overflow-hidden flex-nowrap"



-- Header


viewHeader : Model -> View contentMsg -> Html contentMsg
viewHeader model content =
    header
        [ class headerClass ]
        [ div [ class "flex-grow text-3xl " ]
            [ text content.title ]
        ]



-- Footer


viewFooter : Props -> Html Msg
viewFooter props =
    let
        widthp =
            String.fromFloat (100.0 * (toFloat props.step / toFloat (props.totalSteps - 1))) ++ "%"

        progress =
            String.fromInt (props.step + 1) ++ "/" ++ String.fromInt props.totalSteps
    in
    footer [ class footerClass ]
        [ div
            [ class "w-1/3 border"
            ]
            [ div
                [ class "bg-green-500 p-0.5 text-center text-xs font-medium leading-none text-primary-100"
                , style "width" widthp
                ]
                [ text progress ]
            ]
        ]



-- Pane 1


viewContentPane : Model -> View contentMsg -> Html contentMsg
viewContentPane model content =
    div
        [ class "relative flex flex-col items-start justify-start overflow-x-hidden overflow-y-auto prose prose-zinc prose-headings:font-bold prose-a:decoration-2 hover:prose-a:decoration-rose-500 px-8 min-w-0 pb-12"
        , style "pointer-events" (toPointerEvent model.resizeState)
        , style "user-select" (toPointerEvent model.resizeState)
        , style "min-width" (String.fromFloat (100.0 * toFraction model.resizeState / model.screenWidth) ++ "vw")
        ]
        content.body



-- Resizer


viewResizer : Model -> Html Msg
viewResizer model =
    div
        [ class "bg-rose-500 cursor-col-resize select-none w-2 flex-none"
        , style "left" (String.fromFloat (100.0 * toFraction model.resizeState) ++ "vw")
        , HE.on "mousedown" (Decode.succeed ResizeStart)
        ]
        []



-- Pane 2


viewTerminalPane : Model -> Html contentMsg
viewTerminalPane model =
    div
        [ class "flex-grow p-0 w-full h-full overflow-hidden"
        , style "min-width" (String.fromFloat (100.0 * (1.0 - toFraction model.resizeState)) ++ "vw")
        , style "pointer-events" (toPointerEvent model.resizeState)
        , style "user-select" (toPointerEvent model.resizeState)
        ]
        [ iframe [ class "w-full h-full", src "http://localhost:8900/" ] [] ]
