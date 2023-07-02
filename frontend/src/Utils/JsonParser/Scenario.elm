module Utils.JsonParser.Scenario exposing (..)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)



-- Type Aliases


type alias Scenario =
    { pathwayTitle : String
    , title : String
    , description : String
    , time : String
    , difficulty : String
    , details : Details
    , environment : Environment
    , backend : Backend
    }


type alias Details =
    { steps : List Step
    , intro : Intro
    , finish : Finish
    }


type alias Step =
    { title : String
    , text : String
    , foreground : String
    , background : String
    , verify : String
    }


type alias Intro =
    { title : String
    , text : String
    , foreground : String
    , background : String
    , verify : String
    }


type alias Finish =
    { title : String
    , text : String
    , foreground : String
    , background : String
    , verify : String
    }


type alias Environment =
    { uilayout : String
    }


type alias Backend =
    { imageid : String
    }



-- Parser


scenarioDecoder : Decoder Scenario
scenarioDecoder =
    Decode.succeed Scenario
        |> optional "pathwayTitle" Decode.string ""
        |> required "title" Decode.string
        |> required "description" Decode.string
        |> optional "time" Decode.string ""
        |> optional "difficulty" Decode.string ""
        |> required "details" detailsDecoder
        |> optional "environment" environmentDecoder (Environment "")
        |> required "backend" backendDecoder


detailsDecoder : Decoder Details
detailsDecoder =
    Decode.succeed Details
        |> required "steps" (Decode.list stepDecoder)
        |> required "intro" introDecoder
        |> required "finish" finishDecoder


stepDecoder : Decoder Step
stepDecoder =
    Decode.succeed Step
        |> required "title" Decode.string
        |> required "text" Decode.string
        |> optional "foreground" Decode.string ""
        |> optional "background" Decode.string ""
        |> optional "verify" Decode.string ""


introDecoder : Decoder Intro
introDecoder =
    Decode.succeed Intro
        |> optional "title" Decode.string ""
        |> required "text" Decode.string
        |> optional "foreground" Decode.string ""
        |> optional "background" Decode.string ""
        |> optional "verify" Decode.string ""


finishDecoder : Decoder Finish
finishDecoder =
    Decode.succeed Finish
        |> optional "title" Decode.string ""
        |> required "text" Decode.string
        |> optional "foreground" Decode.string ""
        |> optional "background" Decode.string ""
        |> optional "verify" Decode.string ""


environmentDecoder : Decoder Environment
environmentDecoder =
    Decode.succeed Environment
        |> required "uilayout" Decode.string


backendDecoder : Decoder Backend
backendDecoder =
    Decode.succeed Backend
        |> required "imageid" Decode.string
