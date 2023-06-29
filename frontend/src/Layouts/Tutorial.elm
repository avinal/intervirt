module Layouts.Tutorial exposing (Model, Msg, Props, layout)

import Browser.Events as BE
import Debug
import Effect exposing (Effect)
import Html exposing (Html, button, div, footer, header, iframe, text)
import Html.Attributes exposing (class, src, style)
import Html.Events as HE
import Json.Decode as Decode
import Layout exposing (Layout)
import Route exposing (Route)
import Shared
import View exposing (View)


type alias Props =
    {}


layout : Props -> Shared.Model -> Route () -> Layout () Model Msg contentMsg
layout props shared route =
    Layout.new
        { init = init shared
        , update = update
        , view = view
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
    ( { resizeState = NotResizing (0.5 * shared.screenWidth), screenWidth = shared.screenWidth }
    , Effect.none
    )



-- UPDATE


type Msg
    = ResizeStart
    | ResizeInProgress Bool Float
    | ResizeStop Float


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    let
        _ =
            Debug.log "model" model.resizeState
    in
    case msg of
        ResizeStart ->
            ( { model | resizeState = Resizing (toFraction model.resizeState) }
            , Effect.none
            )

        ResizeInProgress isDown fraction ->
            let
                _ =
                    Debug.log "rezinig" fraction

                _ =
                    Debug.log "isDown" isDown
            in
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
    let
        _ =
            Debug.log "submodel" model
    in
    case model.resizeState of
        Resizing _ ->
            Sub.batch
                [ BE.onMouseMove <| Decode.map2 ResizeInProgress decodeButton <| Decode.field "pageX" Decode.float
                , BE.onMouseUp <| Decode.map ResizeStop <| Decode.field "pageX" Decode.float
                ]

        NotResizing _ ->
            Sub.none



-- decodeFraction : Decode.Decoder Float
-- decodeFraction =
--     Decode.map Decode.field "pageX" Decode.float


decodeButton : Decode.Decoder Bool
decodeButton =
    Decode.field "buttons" (Decode.map (\buttons -> buttons == 1) Decode.int)



-- VIEW


view : { toContentMsg : Msg -> contentMsg, content : View contentMsg, model : Model } -> View contentMsg
view { toContentMsg, model, content } =
    { title = content.title
    , body =
        [ div [ class containerClass ]
            [ viewHeader model |> Html.map toContentMsg
            , div [ class paneContainerClass ]
                [ viewContentPane model |> Html.map toContentMsg
                , viewResizer model |> Html.map toContentMsg
                , viewTerminalPane model |> Html.map toContentMsg
                ]
            , viewFooter model |> Html.map toContentMsg
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
    "bg-blue-500 text-white p-4 flex items-center sticky top-0 z-10"


footerClass =
    "bg-gray-800 text-white p-4 flex items-center justify-center sticky bottom-0 z-10"


containerClass =
    "flex flex-col h-screen w-full overflow-hidden"


paneContainerClass =
    "flex flex-col md:flex-row flex-grow h-full w-full overflow-hidden flex-nowrap"



-- Header


viewHeader : Model -> Html Msg
viewHeader model =
    header
        [ class headerClass ]
        [ div [ class "flex-grow text-lg font-semibold" ]
            [ text "Tutorial Name" ]
        , div [ class "absolute top-1/2 right-1/2 px-2 py-1 text-xs" ]
            [ text (String.fromFloat <| toFraction model.resizeState / model.screenWidth) ]
        , button [ class "ml-4 p-2 hover:bg-blue-700" ]
            [ text "Button 1" ]
        , button [ class "ml-4 p-2 hover:bg-blue-700" ]
            [ text "Button 2" ]
        ]



-- Footer


viewFooter : Model -> Html Msg
viewFooter _ =
    footer [ class footerClass ]
        [ text "Footer Content"
        ]



-- Pane 1


viewContentPane : Model -> Html Msg
viewContentPane model =
    div
        [ class "relative flex flex-col items-start justify-start overflow-x-hidden overflow-y-auto prose prose-zinc px-8 min-w-0 pb-12"
        , style "pointer-events" (toPointerEvent model.resizeState)
        , style "user-select" (toPointerEvent model.resizeState)
        , style "min-width" (String.fromFloat (100.0 * toFraction model.resizeState / model.screenWidth) ++ "vw")
        ]
        [ Html.node "markdown-renderer"
            [ Html.Attributes.attribute "markdowndata" data, class "relative w-full" ]
            []
        ]



-- Resizer


viewResizer : Model -> Html Msg
viewResizer model =
    div
        [ class "bg-cyan-800 cursor-col-resize select-none w-2 flex-none"
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


data =
    """
### Language Rules

As mentioned above CMake is a language itself hence there are some
language rules related to syntax, comments, variables, etc.

- There are two types of comment in CMake, both start with `#`
    character. The first one is line comments, as clear by name it is
    delimited by a newline. The other one is bracket comment and can
    span until the matching brackets are found.

    ```cmake
    # This is a line comment and it ends with the line.

    #[[This is a bracket comment and it can span up to multiple lines.
    But it is only supported in CMake 3.0 or later.]]
    ```

- Variables in CMake are like any other programming language. They are
    case-sensitive and have any alphanumeric characters. In general, it
    is recommended using upper case names as variables. They can be
    assigned and unassigned using `set` and `unset` commands. A variable
    can be referenced using `${VARIABLE_NAME}`.

    > CMake reserves some types of identifers:
    >
    > - begin with **CMAKE_**(upper-, lower-, or mixed-case)
    > - begin with ***CMAKE***(upper-, lower-, or mixed-case)
    > - begin with **_** followed by the name of any CMake Command

- The CMake commands are case insensitive in the latest version (3.0)
    of CMake. That means `message()`, `Message()` or `MESSAGE()` are all
    same.
"""
