module Main exposing (..)

import Browser
import Browser.Events exposing (onAnimationFrame, onClick)
import Color exposing (Color)
import Html exposing (Html, button, div, text)
import Json.Decode as D
import Math.Vector2 as Vec2 exposing (Vec, vec2)
import Random
import Svg exposing (..)
import Svg.Attributes exposing (..)



-- CONSTANTS


forceConstant : Int
forceConstant =
    1


density : Int
density =
    1


zeroVector : Vec Float
zeroVector =
    vec2 0 0



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
    , initialParticles : Int
    , minRadius : Int
    , maxRadius : Int
    , forceConstant : Int
    }



-- Particle


type alias Particle =
    { position : Vec Float
    , velocity : Vec Float
    , r : Int
    , color : Color
    }


charge : Particle -> Int
charge particle =
    particle.r


mass : Particle -> Float
mass particle =
    density * particle.r * particle.r |> toFloat


applyForce : Particle -> Vec Float -> Particle
applyForce particle force =
    let
        acceleration =
            Vec2.divBy (mass particle) force
    in
    { particle | velocity = Vec2.add particle.velocity acceleration }


updateParticle : Config -> Particle -> Particle
updateParticle config particle =
    let
        position =
            Vec2.add particle.position particle.velocity
                |> Vec2.mapX (clamp 0 (toFloat config.width))
                |> Vec2.mapY (clamp 0 (toFloat config.height))
    in
    { particle | position = position }


viewParticle : Particle -> Svg.Svg msg
viewParticle particle =
    circle
        [ cx (String.fromFloat (Vec2.getX particle.position))
        , cy (String.fromFloat (Vec2.getY particle.position))
        , r (String.fromInt particle.r)
        , fill (Color.toCssString particle.color)
        ]
        []


pairwiseForce : Particle -> Particle -> Vec Float
pairwiseForce p1 p2 =
    Vec2.direction p1.position p2.position
        -- it is not necessary to scale each pair by forceConstant, can just multiply the sum after all the force calculations
        |> Vec2.scale (toFloat (forceConstant * charge p1 * charge p2) / Vec2.distanceSquared p1.position p2.position)



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
            , initialParticles = 10
            , minRadius = 5
            , maxRadius = 50
            , forceConstant = 1
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


calculateForce : List Particle -> Int -> Particle -> Vec Float
calculateForce particles index particle =
    List.indexedMap
        (\j other ->
            if j == index then
                zeroVector

            else
                pairwiseForce particle other
        )
        particles
        |> List.foldl Vec2.add zeroVector


step : Model -> Model
step model =
    -- opportunity for memoization and other performance improvements but initial goal is have something that works slowly but works
    let
        particles =
            List.indexedMap
                (\index particle ->
                    calculateForce model.particles index particle |> applyForce particle
                )
                model.particles
                |> List.map (updateParticle model.config)
    in
    { model | particles = particles }


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
            ( step model, Cmd.none )


positionGenerator : Config -> Random.Generator (Vec Float)
positionGenerator config =
    Random.map2 vec2
        (Random.int 0 config.width)
        (Random.int 0 config.height)
        |> Random.map Vec2.toFloat


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
        (positionGenerator config)
        (Random.constant zeroVector)
        (Random.int config.minRadius config.maxRadius)
        colorGenerator



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ if List.length model.particles <= model.config.initialParticles then
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
