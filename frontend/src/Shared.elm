module Shared exposing
    ( Flags, decoder
    , Model, Msg
    , init, update, subscriptions
    )

{-|

@docs Flags, decoder
@docs Model, Msg
@docs init, update, subscriptions

-}

import Effect exposing (Effect)
import Json.Decode
import Route exposing (Route)
import Route.Path
import Shared.Model
import Shared.Msg



-- FLAGS


type alias Flags =
    { screenWidth : Float, screenHeight : Float }


decoder : Json.Decode.Decoder Flags
decoder =
    Json.Decode.map2 Flags
        (Json.Decode.field "windowWidth" Json.Decode.float)
        (Json.Decode.field "windowHeight" Json.Decode.float)



-- INIT


type alias Model =
    Shared.Model.Model


init : Result Json.Decode.Error Flags -> Route () -> ( Model, Effect Msg )
init flagsResult route =
    case flagsResult of
        Ok flags ->
            ( { screenWidth = flags.screenWidth
              , screenHeight = flags.screenHeight
              }
            , Effect.none
            )

        Err _ ->
            ( { screenWidth = 0.0, screenHeight = 0.0 }
            , Effect.none
            )



-- UPDATE


type alias Msg =
    Shared.Msg.Msg


update : Route () -> Msg -> Model -> ( Model, Effect Msg )
update route msg model =
    case msg of
        Shared.Msg.ExampleMsgReplaceMe ->
            ( model
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Route () -> Model -> Sub Msg
subscriptions route model =
    Sub.none
