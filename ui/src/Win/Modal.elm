module Win.Modal exposing (Visibility, hidden, shown, view)

import Bootstrap.Modal as Modal
import Html exposing (Html, button, text)
import Html.Events exposing (onClick)
import Msg exposing (Msg(..))
import Rating exposing (State)
import RemoteData exposing (WebData)
import Time exposing (Posix)
import Win.Score exposing (GameResult, Score)
import Win.WinningView as WinningView


type alias Visibility =
    Modal.Visibility


shown : Visibility
shown =
    Modal.shown


{-| The modal should be hidden
-}
hidden : Visibility
hidden =
    Modal.hidden


view :
    { a
        | class : String -> Html.Attribute Msg
        , startTime : Posix
        , endTime : Posix
        , highScores : WebData (List Score)
        , gameResult : GameResult
        , ratingState : State
        , submittedScoreResponse : WebData ()
        , modalVisibility : Modal.Visibility
    }
    -> Html Msg
view model =
    Modal.config NewGame
        |> Modal.attrs [ model.class "modal-container" ]
        |> Modal.body []
            [ button [ model.class "close", onClick NewGame ] [ text "×" ]
            , WinningView.view model
            ]
        |> Modal.view model.modalVisibility