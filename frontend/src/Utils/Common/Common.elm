module Utils.Common.Common exposing (..)

import Http exposing (Error(..))
import String


type alias CourseSource =
    { user : String
    , repo : String
    , ref : String
    , directory : String
    }


parseCourseSource : String -> Result String CourseSource
parseCourseSource url =
    let
        parts =
            String.split "/" url
                |> List.drop 3
    in
    case parts of
        [ user, repo, "tree", ref, directory ] ->
            Ok { user = user, repo = repo, ref = ref, directory = directory }

        _ ->
            Err "Invalid course source"


urlToScenarioConfig : CourseSource -> String
urlToScenarioConfig c =
    "https://raw.githubusercontent.com/"
        ++ c.user
        ++ "/"
        ++ c.repo
        ++ "/"
        ++ c.ref
        ++ "/"
        ++ c.directory
        ++ "/"


errorToString : Http.Error -> String
errorToString error =
    case error of
        BadUrl url ->
            "The URL " ++ url ++ " was invalid"

        Timeout ->
            "Unable to reach the server, try again"

        NetworkError ->
            "Unable to reach the server, check your network connection"

        BadStatus 500 ->
            "The server had a problem, try again later"

        BadStatus 400 ->
            "Verify your information and try again"

        BadStatus _ ->
            "The content can't be found, please check your url"

        BadBody errorMessage ->
            errorMessage
