module Win.Modal exposing (view)

import Bootstrap.Modal as Modal
import Html exposing (Html, button, text)
import Html.Events exposing (onClick)
import Msg exposing (Msg(..))
import Win.WinningView as WinningView


view model =
    Modal.config NewGame
        |> Modal.attrs [ model.class "modal-container" ]
        |> Modal.body []
            [ button [ model.class "close", onClick NewGame ] [ text "×" ]
            , WinningView.view model
            ]
        |> Modal.view model.modalVisibility
