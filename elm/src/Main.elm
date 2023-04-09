module Main exposing (..)

import Browser
import Browser.Events exposing (onAnimationFrame, onClick)
import Color exposing (Color)
import Html exposing (Html, button, div, text)
import Json.Decode as D
import Random
import Svg exposing (..)
import Svg.Attributes exposing (..)



-- MAIN


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- CONFIG


type alias Config =
    { width : Int
    , height : Int
    , maxParticles : Int
    , minRadius : Int
    , maxRadius : Int
    }



-- Particle


type alias Particle =
    { x : Int
    , y : Int
    , r : Int
    , color : Color
    }


viewParticle : Particle -> Svg.Svg msg
viewParticle particle =
    circle
        [ cx (String.fromInt particle.x)
        , cy (String.fromInt particle.y)
        , r (String.fromInt particle.r)
        , fill (Color.toCssString particle.color)
        ]
        []



-- MODEL


type alias Model =
    { config : Config
    , particles : List Particle
    }


init : () -> ( Model, Cmd Msg )
init () =
    let
        config =
            { width = 500
            , height = 500
            , maxParticles = 10
            , minRadius = 5
            , maxRadius = 50
            }
    in
    let
        model =
            { config = config, particles = [] }
    in
    ( model
    , Random.generate AddParticle (particleGenerator config)
    )



-- UPDATE


type Msg
    = AddParticle Particle
    | GenerateParticle
    | Step


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddParticle particle ->
            ( { model | particles = particle :: model.particles }
            , Cmd.none
            )

        GenerateParticle ->
            ( model
            , Random.generate AddParticle (particleGenerator model.config)
            )

        Step ->
            ( model, Cmd.none )


colorGenerator : Random.Generator Color
colorGenerator =
    Random.map4 Color.rgba
        (Random.float 0.0 1.0)
        (Random.float 0.0 1.0)
        (Random.float 0.0 1.0)
        (Random.float 0.0 1.0)


particleGenerator : Config -> Random.Generator Particle
particleGenerator config =
    Random.map4 Particle
        (Random.int 0 config.width)
        (Random.int 0 config.height)
        (Random.int config.minRadius config.maxRadius)
        colorGenerator



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ if List.length model.particles <= model.config.maxParticles then
            onAnimationFrame (\_ -> GenerateParticle)

          else
            Sub.none
        , onAnimationFrame (\_ -> Step)
        , onClick (D.succeed GenerateParticle)
        ]



-- VIEW


view : Model -> Html Msg
view model =
    svg
        [ width (String.fromInt model.config.width)
        , height (String.fromInt model.config.height)
        , viewBox (String.join " " [ "0", "0", String.fromInt model.config.width, String.fromInt model.config.height ])
        ]
        (List.map viewParticle model.particles)
