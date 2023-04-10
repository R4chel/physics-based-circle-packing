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
    10


density : Float
density =
    0.5


zeroVector : Vec Float
zeroVector =
    vec2 0 0


maxVelocityMagnitude : Float
maxVelocityMagnitude =
    100


maxVelocityMagnitudeSquared : Float
maxVelocityMagnitudeSquared =
    maxVelocityMagnitude * maxVelocityMagnitude



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


type Sign
    = Positive
    | Negative


type alias Particle =
    { position : Vec Int
    , velocity : Vec Float
    , r : Int
    , color : Color
    , sign : Sign
    }


charge : Particle -> Int
charge particle =
    case particle.sign of
        Positive ->
            particle.r

        Negative ->
            -1 * particle.r


mass : Particle -> Float
mass particle =
    density * toFloat (particle.r * particle.r)


applyForce : Particle -> Vec Float -> Particle
applyForce particle force =
    let
        acceleration =
            Vec2.divBy (mass particle) force
    in
    let
        uncheckedVelocity =
            Vec2.add particle.velocity acceleration
    in
    let
        magnitudeSquared =
            Vec2.lengthSquared uncheckedVelocity
    in
    let
        velocity =
            if magnitudeSquared <= maxVelocityMagnitudeSquared then
                uncheckedVelocity

            else
                Vec2.normalize uncheckedVelocity |> Vec2.scale maxVelocityMagnitude
    in
    { particle | velocity = velocity }


updateParticle : Config -> Particle -> Particle
updateParticle config particle =
    let
        velocity =
            particle.velocity
                |> (\v ->
                        if Vec2.getX particle.position < 0 || Vec2.getX particle.position > config.width then
                            Vec2.mapX negate v

                        else
                            v
                   )
                |> Vec2.mapY
                    (\vy ->
                        if Vec2.getY particle.position < 0 || Vec2.getY particle.position > config.height then
                            -1 * vy

                        else
                            vy
                    )
    in
    let
        position =
            Vec2.add particle.position (Vec2.truncate velocity)
                |> Vec2.mapX (clamp -particle.r (config.width + particle.r))
                |> Vec2.mapY (clamp -particle.r (config.height + particle.r))
    in
    { particle | position = position, velocity = velocity }


viewParticle : Particle -> Svg.Svg msg
viewParticle particle =
    circle
        [ cx (String.fromInt (Vec2.getX particle.position))
        , cy (String.fromInt (Vec2.getY particle.position))
        , r (String.fromInt particle.r)
        , fill (Color.toCssString particle.color)
        ]
        []


pairwiseForce : Particle -> Particle -> Vec Float
pairwiseForce p1 p2 =
    if p1.position == p2.position then
        zeroVector

    else
        let
            pos1 =
                Vec2.toFloat p1.position
        in
        let
            pos2 =
                Vec2.toFloat p2.position
        in
        Vec2.direction pos1 pos2
            -- it is not necessary to scale each pair by forceConstant, can just multiply the sum after all the force calculations
            |> Vec2.scale (toFloat (forceConstant * charge p1 * charge p2) / Vec2.distanceSquared pos1 pos2)



-- MODEL


type alias Model =
    { config : Config
    , particles : List Particle
    , fixedParticles : List Particle
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
        cornerCharge position =
            Particle position zeroVector 200 Color.black Positive
    in
    let
        model =
            { config = config
            , particles = []
            , fixedParticles =
                -- gravitywell
                Particle (vec2 (config.width // 2) (config.height // 2)) zeroVector 100 Color.black Negative
                    :: List.map cornerCharge [ vec2 0 0, vec2 0 config.height, vec2 config.width config.height, vec2 config.width 0 ]
            }
    in
    ( model
    , Random.generate AddParticle (particleGenerator config)
    )



-- UPDATE


type Msg
    = AddParticle Particle
    | GenerateParticle
    | Step


step : Model -> Model
step model =
    -- opportunity for memoization and other performance improvements but initial goal is have something that works slowly but works
    let
        allParticles =
            model.particles ++ model.fixedParticles
    in
    let
        particles =
            List.indexedMap
                (\index particle ->
                    List.indexedMap
                        (\j other ->
                            if j == index then
                                zeroVector

                            else
                                pairwiseForce particle other
                        )
                        allParticles
                        |> List.foldl Vec2.add zeroVector
                        |> applyForce particle
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


positionGenerator : Config -> Random.Generator (Vec Int)
positionGenerator config =
    Random.map2 vec2
        (Random.int 0 config.width)
        (Random.int 0 config.height)


velocityGenerator : Random.Generator (Vec Float)
velocityGenerator =
    Random.map2 vec2
        (Random.float -10 10)
        (Random.float -1 1)


colorGenerator : Random.Generator Color
colorGenerator =
    Random.map4 Color.rgba
        (Random.float 0.0 1.0)
        (Random.float 0.0 1.0)
        (Random.float 0.0 1.0)
        (Random.float 0.0 1.0)


particleGenerator : Config -> Random.Generator Particle
particleGenerator config =
    Random.map5 Particle
        (positionGenerator config)
        velocityGenerator
        (Random.int config.minRadius config.maxRadius)
        colorGenerator
        (Random.constant Positive)



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
