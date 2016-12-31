# Description:
#   Confessions!
#
# Configuration:
#   HUBOT_CONFESS_ROOM
#
# Commands:
#   hubot confess <confession> - submit anonymous confession (can be sent in a private message)
#   hubot c0nf3ss <confession> - submit super anonymous confession (can be sent in a private message)
#   hubot anonymous <confession> - submit confession that will be automatically anonymized (can be sent in a private message)
#
# Author:
#   anishathalye

gtranslate = require 'node-google-translate-skidz'

module.exports = (robot) ->

  config = require('hubot-conf')('confess', robot)

  robot.respond /confess (.+)$/i, (res) ->
    text = "[Confession] #{res.match[1]}"
    room = config('room')
    robot.send {room: room}, text

  robot.respond /c0nf3ss (.+)$/i, (res) ->
    text = "[Confession] #{res.match[1]}"
    room = config('room')
    robot.send {room: room}, translate(text)

  robot.respond /anonymous (.+)$/i, (res) ->
    text = res.match[1]
    language = 'en'
    intermediates = ['es', 'de', 'hi', 'fr', 'af', 'en']
    chain = (lang, int) -> (text) ->
      # we get a Translation object in the callback from gtranslate, and we
      # need to extract .translation
      if typeof(text) != 'string'
        text = text.translation
      if int.length > 0
        next = int.shift()
        gtranslate {text: text, source: lang, target: next}, chain(next, int)
      else
        message = "[Anonymous] #{text}"
        room = config 'room'
        robot.send {room: room}, message
    chain(language, intermediates)(text)


translate = (text) ->
  `var firstCharacter`
  `var firstCharacter`
  `var k`
  # stolen from http://www.punkwalrus.com/cybertusk/text2aol.html
  # change it all to uppercase
  text = text.toUpperCase()
  # split the string into an array
  textArray = text.split(' ')
  # create output and length variables
  output = ''
  arrayLength = textArray.length
  wordLength = undefined
  # start loop which translates what's written
  i = 0
  while i < arrayLength
    # create variable for how long the current word is
    wordLength = textArray[i].length
    # test if the word is any special words; if so, change it to associated misspelling/abbreviation
    if textArray[i].indexOf('YOUR') != -1 or textArray[i].indexOf('YOU\'RE') != -1
      output += 'UR'
    else if textArray[i].indexOf('YOU') != -1
      output += 'U'
    else if (textArray[i] + ' ' + textArray[i + 1]).indexOf('WHAT THE') != -1
      output += 'WT'
      if textArray[i + 2].indexOf('FUCK') != -1 and textArray[i + 2].charAt(textArray[i + 2].indexOf('FUCK') + 4) != 'I'
        # if phrase is "what the fuck", write "F"
        output += 'F'
        i++
      else if textArray[i + 2].indexOf('HELL') != -1 or textArray[i + 2].indexOf('HECK') != -1
        # if phrase is "what the hell", write "H"
        output += 'H'
        i++
      # end if
      i++
    else if textArray[i].indexOf('WHAT') != -1
      output += 'WUT'
    else if textArray[i].indexOf('ARE') != -1 and textArray[i].indexOf('ARE') + 3 == wordLength
      output += 'R'
    else if textArray[i].indexOf('WHY') != -1
      output += 'Y'
    else if (textArray[i] + ' ' + textArray[i + 1] + ' ' + textArray[i + 2]).indexOf('BE RIGHT BACK') != -1
      output += 'BRB'
      i += 2
    else if textArray[i].indexOf('BECAUSE') != -1
      output += 'B/C'
    else if (textArray[i] + ' ' + textArray[i + 1] + ' ' + textArray[i + 2]).indexOf('OH MY GOD') != -1
      output += 'OMG'
      i += 2
    else if textArray[i].indexOf('OH') != -1
      output += 'O'
    else if textArray[i].indexOf('THE') != -1 and textArray[i].indexOf('THE') + 3 == wordLength
      if Math.floor(Math.random() * 100) % 2
        output += 'TEH'
      else
        output += 'DA'
    else if textArray[i].indexOf('MY') != -1 and textArray[i].indexOf('MY') + 2 == wordLength
      output += 'MAH'
    else if textArray[i].indexOf('NEW') != -1 and textArray[i].indexOf('NEW') + 3 == wordLength
      output += 'NU'
    else if textArray[i].indexOf('WITH') != -1 and textArray[i].indexOf('WITH') + 4 == wordLength
      output += 'WIT'
    else if textArray[i].indexOf('REALLY') != -1
      output += 'RILLY'
    else if textArray[i].indexOf('PLEASE') != -1
      output += 'PLZ'
    else if textArray[i].indexOf('THANKS') != -1
      output += 'THX'
    else if textArray[i].indexOf('THERE') != -1
      if Math.floor(Math.random() * 100) % 2
        output += 'THEIR'
      else
        output += 'THEYRE'
    else if textArray[i].indexOf('THEIR') != -1
      if Math.floor(Math.random() * 100) % 2
        output += 'THERE'
      else
        output += 'THEYRE'
    else if textArray[i].indexOf('THEY\'RE') != -1
      if Math.floor(Math.random() * 100) % 2
        output += 'THERE'
      else
        output += 'THEIR'
    else if textArray[i].indexOf('OK') != -1 and textArray[i].indexOf('OK') + 2 == wordLength and textArray[i].indexOf('OK') == 0
      output += 'K'
    else if textArray[i].indexOf('OKAY') != -1 and textArray[i].indexOf('OKAY') + 4 == wordLength
      output += 'K'
    else if textArray[i].indexOf('LIBRARY') != -1
      output += 'LIBERRY'
    else
      # if the word is none of those things, check to see if individual letters are special letters
      j = 0
      while j < wordLength
        # delete double-letters; AOLers aren't that capable of spelling
        if textArray[i].charAt(j) == textArray[i].charAt(j + 1)
          output += textArray[i].charAt(j)
          j++
        else if textArray[i].charAt(j) == 'B'
          output += 'B'
          if textArray[i].charAt(j + 1) == 'E'
            j++
        else if textArray[i].charAt(j) == 'C'
          if textArray[i].charAt(j + 1) == 'K'
            output += 'K'
            j++
          else
            output += 'C'
        else if textArray[i].charAt(j) == 'E'
          if Math.floor(Math.random() * 100) % 3 == 2
            output += '3'
          else if Math.floor(Math.random() * 100) % 3 == 1
            output += 'A'
          else
            output += 'E'
        else if textArray[i].charAt(j) == 'I'
          # if there's an -ing word, change it to -ng
          if textArray[i].charAt(j + 1) + textArray[i].charAt(j + 2) == 'NG'
            output += 'NG'
            j += 2
          else if textArray[i].charAt(j + 2) == 'E'
            output += 'IE' + textArray[i].charAt(j + 1)
            j += 2
          else if textArray[i].charAt(j + 1) == 'E'
            output += 'EI'
            j++
          else if textArray[i].charAt(j + 1) + textArray[i].charAt(j + 2) == '\'M' and j + 3 == wordLength
            if textArray[i + 1] + ' ' + textArray[i + 2] == 'GOING TO'
              output += 'IMA'
              i += 2
              j += 2
            else
              output += 'IM'
          else if textArray[i + 1] == 'AM'
            if textArray[i + 2] + ' ' + textArray[i + 3] == 'GOING TO'
              output += 'IMA'
              i += 3
            else
              output += 'IM'
              i++
          else
            output += 'I'
        else if textArray[i].charAt(j) == 'A'
          if textArray[i].charAt(j + 1) == 'M'
            output += 'M'
            j++
          else if textArray[i].charAt(j + 1) + textArray[i].charAt(j + 2) == 'LK'
            output += 'OK'
            j += 2
          else if textArray[i].charAt(j + 1) == 'I'
            output += 'A' + textArray[i].charAt(j + 2) + 'E'
            j += 2
          else if textArray[i].charAt(j + 1) + textArray[i].charAt(j + 2) + textArray[i].charAt(j + 3) == 'TER'
            output += '8R'
            j += 3
          else if textArray[i].charAt(j + 2) == 'E'
            output += 'AE' + textArray[i].charAt(j + 1)
            j += 2
          else
            output += 'A'
        else if textArray[i].charAt(j) == 'S'
          if textArray[i].charAt(j + 1) + textArray[i].charAt(j + 2) + textArray[i].charAt(j + 3) + textArray[i].charAt(j + 4) + textArray[i].charAt(j + 5) == 'CHOOL'
            output += 'SKOOL'
            j += 5
          else if textArray[i].charAt(j + 1) + textArray[i].charAt(j + 2) + ' ' + textArray[i].charAt(0) + textArray[i].charAt(1) + textArray[i].charAt(2) == 'SEE YOU'
            output += 'CYA'
            j += 5
          else if textArray[i].charAt(j + 1) + textArray[i].charAt(j + 2) + ' ' + textArray[i].charAt(0) + textArray[i].charAt(1) == 'SEE YA'
            output += 'CYA'
            j += 5
          else
            output += 'S'
        else if textArray[i].charAt(j) == 'O'
          # test to see if it's a double-O word or an OUL word; if so, replace letters with a U
          if textArray[i].charAt(j + 1) == 'O'
            output += 'U'
            j++
          else if textArray[i].charAt(j + 1) == 'U' and textArray[i].charAt(j + 2) == 'L'
            output += 'U'
            j += 2
          else
            output += 'O'
        else if textArray[i].charAt(j) == 'T'
          if textArray[i].charAt(j + 1) == 'O'
            output += '2'
            if textArray[i].charAt(j + 2) == 'O'
              j += 2
            else
              j++
            # end else
          else if textArray[i].charAt(j + 1) + textArray[i].charAt(j + 2) + textArray[i].charAt(j + 3) == 'HAT'
            output += 'TAHT'
            j += 3
          else
            output += 'T'
        else if textArray[i].charAt(j) != '.' and textArray[i].charAt(j) != '!' and textArray[i].charAt(j) != '?' and textArray[i].charAt(j) != '\'' and textArray[i].charAt(j) != ';' and textArray[i].charAt(j) != ',' and textArray[i].charAt(j) != ':' and textArray[i].charAt(j) != '"' and textArray[i].charAt(j) != '`' and textArray[i].charAt(j) != '~'
          output += textArray[i].charAt(j)
        j++
      # end for
    # end else
    # replace end punctuation with more AOLer style punctuation
    if textArray[i].indexOf('.') != -1 or textArray[i].indexOf('!') != -1 or textArray[i].indexOf('?') != -1
      # create a loop variable
      placeInWord = undefined
      # find out which character comes first
      if textArray[i].indexOf('!') != -1
        firstCharacter = '!'
      else if textArray[i].indexOf('.') != -1
        firstCharacter = '.'
      else if textArray[i].indexOf('?') != -1
        firstCharacter = '?'
      if textArray[i].indexOf('.') < textArray[i].indexOf(firstCharacter) and textArray[i].indexOf('.') != -1
        firstCharacter = '.'
      if textArray[i].indexOf('?') < textArray[i].indexOf(firstCharacter) and textArray[i].indexOf('?') != -1
        firstCharacter = '?'
      # set where to start in the word
      placeInWord = textArray[i].indexOf(firstCharacter)
      # if there is a question mark...
      if textArray[i].indexOf('?') != -1
        # ...ensure there is at least one question mark in the output
        output += '?'
      # end if
      while textArray[i].charAt(placeInWord) == '.' or textArray[i].charAt(placeInWord) == '!' or textArray[i].charAt(placeInWord) == '?'
        if textArray[i].charAt(placeInWord) == '!' or textArray[i].charAt(placeInWord) == '.'
          # output a random amount of exclamation marks and 1's
          k = Math.floor(Math.random() * 100) % 5 + 4
          while k > 0
            if Math.floor(Math.random() * 100) % 2
              output += '!'
            else
              output += '1'
            k--
        else if textArray[i].charAt(placeInWord) == '?'
          # output a random amount of question marks and exclamation marks
          k = Math.floor(Math.random() * 100) % 5 + 4
          while k > 0
            if Math.floor(Math.random() * 100) % 2
              output += '?'
            else
              output += '!'
            k--
        # end else
        placeInWord++
      # end for
      # randomly print any combination of the abbreviations "OMG", "WTF", and "LOL" at the end of sentences
      if Math.floor(Math.random() * 100) % 2
        output += ' OMG'
      if Math.floor(Math.random() * 100) % 2
        output += ' WTF'
      if Math.floor(Math.random() * 100) % 2
        output += ' LOL'
    # end if
    # put a space between each word if it's not the end of a sentence
    if i != arrayLength - 1 and textArray[i + 1] != ''
      output += ' '
    i++
  # end for
  # output the result to the bottom box
  output = output.toLowerCase()
  output
