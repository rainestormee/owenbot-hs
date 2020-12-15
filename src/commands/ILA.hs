{-# LANGUAGE OverloadedStrings #-}

module ILA (sendThmChan, sendDefChan, sendLemChan, sendTextbookChan) where

import qualified Discord.Requests as R
import Discord.Types
import Discord

import CommandHandler (sendMessageChan, sendFileChan)
import Data.Bifunctor (first)

sendThmChan :: ChannelId -> T.Text -> DiscordHandler (Either RestCallErrorCode Message)
sendThmChan chan content = sendFileChan chan ("Theorem "                      <> parse content)
                                             ("./src/assets/ila/theorems/"    ++ parseStr content)

sendDefChan :: ChannelId -> T.Text -> DiscordHandler (Either RestCallErrorCode Message)
sendDefChan chan content = sendFileChan chan ("Definition "                   <> parse content)
                                             ("./src/assets/ila/definitions/" ++ parseStr content)

sendLemChan :: ChannelId -> T.Text -> DiscordHandler (Either RestCallErrorCode Message)
sendLemChan chan content = sendFileChan chan ("Lemma "                        <> parse content)
                                             ("./src/assets/ila/lemmas/"      ++ parseStr content)

sendTextbookChan :: ChannelId -> T.Text -> DiscordHandler (Either RestCallErrorCode Message)
sendTextbookChan chan = sendFileChan chan "Textbook.pdf" "./src/assets/textbooks/ila-textbook.pdf"

parseStr :: T.Text -> String
parseStr = T.unpack . parse

parse :: T.Text -> T.Text
parse = uncurry (<>) . first padZeroes 2 . breakOn "." .
        T.intercalate "." . map rmZeroes . T.splitOn "." . rmFuncText

rmZeroes :: T.Text -> T.Text
rmZeroes digits = case T.dropWhile (== '0') digits of
    "" -> "0"
    d' -> d'
                    
padZeroes :: Int -> T.Text -> T.Text
padZeroes newLen digits = T.replicate (newLen - T.length digits) "0" <> digits
                
rmFuncText :: T.Text -> String
rmFuncText = T.dropWhile (\x -> isAlpha x || isSpace x) . T.tail