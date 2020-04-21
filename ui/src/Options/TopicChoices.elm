module Options.TopicChoices exposing (view)

import Game.Square exposing (Topic(..))
import Html exposing (Html, div, input, label, text)
import Html.Attributes exposing (checked, for, name, style, type_)
import Html.Events exposing (onClick)
import Msg exposing (Msg(..))


view :
    { model | class : String -> Html.Attribute Msg, topics : List Topic }
    -> String
    -> Bool
    -> Html Msg
view { class, topics } wrapperClass show =
    if show then
        div [ class wrapperClass ]
            [ title class
            , topicToggle class "Fordisms" Fordism topics
            , topicToggle class "Coronavirus" Coronavirus topics
            ]

    else
        div [] []


title class =
    div [ class "topic-title" ] [ text "topical bingo" ]


topicToggle class topicLabel topic topics =
    div [ style "display" "flex", onClick (TopicToggled topic) ]
        [ div [ class "container" ]
            [ input [ name topicLabel, checked (topics |> List.member topic), type_ "checkbox" ] []
            , div [ class (classNames topic topics) ] []
            ]
        , label
            [ for topicLabel
            , class "label"
            ]
            [ text topicLabel ]
        ]


classNames topic topics =
    if topics |> List.member topic then
        "checkmark checkmark-checked"

    else
        "checkmark"
