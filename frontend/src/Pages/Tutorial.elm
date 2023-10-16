module Pages.Tutorial exposing (Model, Msg, page)

import Array exposing (Array)
import Dict exposing (Dict)
import Effect exposing (Effect)
import Html exposing (button, div, text)
import Html.Attributes exposing (class)
import Html.Events as HE
import Http
import Json.Decode as D
import Json.Encode as Encode
import Layouts
import Page exposing (Page)
import Route exposing (Route)
import Shared
import Utils.Common.Common exposing (CourseSource, errorToString, parseCourseSource, urlToScenarioConfig)
import Utils.JsonParser.Scenario exposing (Finish, Intro, Scenario, Step, scenarioDecoder)
import View exposing (View)


page : Shared.Model -> Route () -> Page Model Msg
page shared route =
    Page.new
        { init = init route
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
        |> Page.withLayout layout



-- LAYOUT


layout : Model -> Layouts.Layout Msg
layout model =
    Layouts.Tutorial
        { step = model.step, totalSteps = Array.length model.totalSteps }



-- INIT


type alias Model =
    { courseSource : Maybe CourseSource
    , scenario : Maybe Scenario
    , content : Maybe String
    , fetchUrl : String
    , error : Maybe String
    , step : Int
    , totalSteps : Array Step
    }


type StepType
    = Next
    | Previous


initialModel : Model
initialModel =
    { courseSource = Nothing
    , scenario = Nothing
    , content = Nothing
    , fetchUrl = ""
    , error = Nothing
    , step = -1
    , totalSteps = Array.fromList []
    }


init : Route () -> () -> ( Model, Effect Msg )
init route () =
    let
        parsedUrl =
            Dict.get "url" route.query
                |> Maybe.withDefault ""
                |> parseCourseSource
    in
    case parsedUrl of
        Ok courseSource ->
            let
                fetchUrl =
                    urlToScenarioConfig courseSource

                cmd : Cmd Msg
                cmd =
                    Http.get
                        { url = fetchUrl ++ "index.json"
                        , expect = Http.expectJson JsonFetch scenarioDecoder
                        }
            in
            ( { initialModel | courseSource = Just courseSource, fetchUrl = fetchUrl }
            , Effect.sendCmd cmd
            )

        Err err ->
            ( initialModel, Effect.none )



-- UPDATE


type Msg
    = ContentFetch (Result Http.Error String)
    | JsonFetch (Result Http.Error Scenario)
    | ChangeStep StepType Int
    | MyMsgHandler (Result Http.Error ())
    | CreateVm


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ContentFetch (Ok content) ->
            ( { model | content = Just content }, Effect.none )

        ContentFetch (Err err) ->
            ( { model | error = Just (errorToString err) }, Effect.none )

        JsonFetch (Ok scenario) ->
            let
                steps =
                    everythingIsStep scenario.details.intro scenario.details.finish scenario.details.steps
            in
            update (ChangeStep Next -1) { model | scenario = Just scenario, totalSteps = steps }

        JsonFetch (Err err) ->
            ( { model | error = Just (errorToString err) }, Effect.none )

        ChangeStep stepType step ->
            case stepType of
                Next ->
                    ( { model | step = model.step + 1 }
                    , Effect.sendCmd (fetchStep model (model.step + 1))
                    )

                Previous ->
                    ( { model | step = model.step - 1 }
                    , Effect.sendCmd (fetchStep model (model.step - 1))
                    )

        MyMsgHandler (Ok _) ->
            ( model, Effect.none )

        MyMsgHandler (Err err) ->
            ( { model | error = Just (errorToString err) }, Effect.none )

        CreateVm ->
            ( {model | step = model.step +1} , Effect.batch [ Effect.sendCmd postVM, Effect.sendCmd (fetchStep model (model.step + 1)) ] )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    case ( model.content, model.scenario ) of
        ( Just content, Just scenario ) ->
            let
                stepTitle =
                    case Array.get model.step model.totalSteps of
                        Just value ->
                            " : " ++ value.title

                        Nothing ->
                            ""
            in
            { title = scenario.title ++ stepTitle
            , body =
                [ Html.node "markdown-renderer"
                    [ Html.Attributes.attribute "markdowndata" content
                    , class "relative w-full pt-5"
                    ]
                    []
                , div [ class "bottom-0 w-full flex bg-white py-2 text-white" ]
                    [ button
                        [ class <|
                            "w-1/2 text-center bg-gray-500 p-2 hover:bg-rose-700 border "
                                ++ (if model.step <= 0 then
                                        "hidden"

                                    else
                                        ""
                                   )
                        , HE.onClick (ChangeStep Previous model.step)
                        ]
                        [ text "Previous" ]
                    , button
                        [ class <|
                            "w-1/2 text-center bg-gray-500 p-2 hover:bg-rose-700 border "
                                ++ (if model.step == Array.length model.totalSteps - 1 then
                                        "hidden"

                                    else
                                        ""
                                   )
                        , HE.onClick <|
                            if model.step == 0 then
                                CreateVm

                            else
                                ChangeStep Next model.step
                        ]
                        [ if model.step == 0 then
                            text "Start"

                          else
                            text "Next"
                        ]
                    ]
                ]
            }

        _ ->
            { title = "Tutorial"
            , body =
                []
            }



-- MISC


fetchStep : Model -> Int -> Cmd Msg
fetchStep model step =
    case Array.get step model.totalSteps of
        Just value ->
            let
                cmd : Cmd Msg
                cmd =
                    Http.get
                        { url =
                            String.append model.fetchUrl value.text
                        , expect = Http.expectString ContentFetch
                        }
            in
            cmd

        Nothing ->
            Cmd.none


everythingIsStep : Intro -> Finish -> List Step -> Array Step
everythingIsStep intro finish steps =
    let
        introStep =
            Step intro.title intro.text intro.foreground intro.background intro.verify

        finishStep =
            Step finish.title finish.text finish.foreground finish.background finish.verify
    in
    [ [ introStep ], steps, [ finishStep ] ]
        |> List.concat
        |> Array.fromList


postVM : Cmd Msg
postVM =
    let
        url =
            "http://localhost:8089/vm"

        body =
            Encode.object
                [ ( "vm_name", Encode.string "fedoraq" )
                , ( "image_name", Encode.string "quay.io/kubevirt/fedora-cloud-container-disk-demo:latest" )
                , ( "memory", Encode.string "4G" )
                ]
    in
    Http.post
        { url = url
        , body = Http.jsonBody body
        , expect = Http.expectWhatever MyMsgHandler -- Replace `MyMsgHandler` with your actual Msg handler for the response
        }
