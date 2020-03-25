module Main exposing (Model, Msg(..), init, main, update, view)

import Bingo exposing (randomBoard)
import Board exposing (Board)
import Browser
import Browser.Navigation as Navigation exposing (Key, load, pushUrl)
import Html exposing (Html, a, button, div, h1, h2, text)
import Html.Attributes exposing (href, style)
import Html.Events exposing (onClick)
import RemoteData exposing (WebData)
import Requests
import Score exposing (GameResult, Score)
import Square exposing (Square, toggleSquareInList)
import Task
import Time exposing (Posix)
import TimeFormatter
import Url exposing (Url)


type Msg
    = GotCurrentTime Time.Posix
    | GotEndTime Time.Posix
    | ToggleCheck Square
    | NewGame
    | HighScoresResponse (WebData (List Score))
    | GameResponse (WebData ())
    | SubmitGame
    | RequestHighScores
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url
    | NoOp


type alias Model =
    { board : Board
    , startTime : Posix
    , endTime : Posix
    , highScores : WebData (List Score)
    , submittedScoreResponse : WebData ()
    , url : Url
    , key : Key
    }


view model =
    { title = "BINGO!"
    , body =
        [ h1
            [ style "text-align" "center"
            , style "font-family" "sans-serif"
            ]
            [ text "CONFERENCE CALL BINGO!" ]
        , div
            [ style "font-size" "12"
            , style "text-align" "center"
            , style "font-family" "sans-serif"
            , style "padding-bottom" "8px"
            ]
            [ text "Powered by ", a [ href "https://www.fordlabs.com" ] [ text "FordLabs" ] ]
        ]
            ++ (if Bingo.isWinner model.board then
                    winningView model

                else
                    boardView model
               )
    }


winningView : Model -> List (Html Msg)
winningView model =
    [ h1
        [ style "text-align" "center"
        , style "font-family" "sans-serif"
        ]
        [ text "Bingo!" ]
    , h2
        [ style "text-align" "center"
        , style "font-family" "sans-serif"
        ]
        [ text ("Your winning time: " ++ TimeFormatter.winingTime model.startTime model.endTime) ]
    , div [ style "text-align" "center" ]
        [ button
            [ style "background-color" "#002F6CCC"
            , style "color" "white"
            , style "border" "none"
            , style "font-size" "18px"
            , style "border-radius" "5px"
            , style "cursor" "pointer"
            , style "padding" "20px"
            , onClick NewGame
            ]
            [ text "Play Again" ]
        ]
    ]


boardView : Model -> List (Html Msg)
boardView model =
    [ div
        [ style "justify-content" "center"
        , style "padding-top" "5px"
        , style "display" "grid"
        , style "grid-template-columns" "repeat(5, 100px)"
        , style "grid-template-rows" "repeat(5, 100px)"
        , style "grid-gap" "10px"
        , style "font-family" "sans-serif"
        ]
        (List.map
            (\square ->
                div
                    [ style "display" "table"
                    , style "height" "100%"
                    , style "width" "100%"
                    ]
                    [ div
                        [ if square.checked then
                            style "background-color" "red"

                          else
                            style "background-color" "#002F6CCC"
                        , onClick (ToggleCheck square)
                        , style "color" "white"
                        , style "border-radius" "5px"
                        , style "cursor" "pointer"
                        , style "vertical-align" "middle"
                        , style "text-align" "center"
                        , style "display" "table-cell"
                        , style "padding" "5px"
                        ]
                        [ text square.text ]
                    ]
            )
            model.board
        )
    ]


init : () -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init _ url key =
    ( { board = []
      , startTime = Time.millisToPosix 0
      , endTime = Time.millisToPosix 0
      , highScores = RemoteData.NotAsked
      , submittedScoreResponse = RemoteData.NotAsked
      , url = url
      , key = key
      }
    , Task.perform GotCurrentTime Time.now
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleCheck squareToToggle ->
            let
                updatedBoard =
                    model.board |> toggleSquareInList squareToToggle
            in
            ( { model | board = updatedBoard }
            , if updatedBoard |> Bingo.isWinner then
                Task.perform GotEndTime Time.now

              else
                Cmd.none
            )

        GotCurrentTime time ->
            ( { model | board = Time.posixToMillis time |> randomBoard, startTime = time }, Cmd.none )

        GotEndTime time ->
            ( { model | endTime = time }, Cmd.none )

        NewGame ->
            ( model, Task.perform GotCurrentTime Time.now )

        HighScoresResponse response ->
            ( { model | highScores = response }, Cmd.none )

        GameResponse response ->
            ( { model | submittedScoreResponse = response }, Cmd.none )

        RequestHighScores ->
            ( model, Requests.getHighScores model.url HighScoresResponse )

        SubmitGame ->
            let
                gameResult =
                    { score = Time.posixToMillis model.endTime - Time.posixToMillis model.startTime
                    , player = "aaa"
                    , suggestion = Just ""
                    , rating = 5
                    }
            in
            ( model, Requests.submitScore model.url GameResponse gameResult )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, load href )

        UrlChanged url ->
            ( { model | url = url }
            , Cmd.none
            )

        NoOp ->
            ( model, Cmd.none )


main =
    Browser.application
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }
