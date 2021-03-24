{-# LANGUAGE BlockArguments #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications #-}

module Main
  ( main,
  )
where

import Filters
import Hakyll
import Text.Pandoc.SideNote

main :: IO ()
main = hakyll do
  match "vendor/tufte-css/tufte.css" do
    route idRoute
    compile compressCssCompiler

  match "et-book/**" do
    route idRoute
    compile getResourceLBS

  match "css/*" $ compile compressCssCompiler

  create ["stylesheet.css"] do
    route idRoute
    compile do
      tufte <- load "vendor/tufte-css/tufte.css"
      csses <- loadAll "css/*.css"
      makeItem $ unlines $ map itemBody $ tufte : csses

  match "posts/*.md" do
    route $ setExtension "html"
    compile $
      customPandoc
        >>= saveSnapshot "content"
        >>= loadAndApplyTemplate "templates/default.html" defaultContext
        >>= relativizeUrls

  create ["atom.xml"] do
    route idRoute
    compile do
      posts <- take 5 <$> (recentFirst =<< loadAll "posts/*")
      let feedCtx =
            listField "posts" defaultContext (pure posts)
              <> defaultContext
      renderAtom feedConfig feedCtx posts

  create ["archive"] do
    route $ setExtension "html"
    compile do
      posts <- recentFirst =<< loadAll "posts/*"
      let archiveCtx =
            listField "posts" defaultContext (pure posts)
              <> constField "title" "Archives"
              <> defaultContext
      makeItem ""
        >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
        >>= loadAndApplyTemplate "templates/default.html" archiveCtx
        >>= relativizeUrls

  create ["CNAME"] do
    route idRoute
    compile $ makeItem @String "blog.arusekk.pl"

  match "about.md" do
    route $ setExtension "html"
    compile $
      customPandoc
        >>= saveSnapshot "content"
        >>= loadAndApplyTemplate "templates/default.html" (constField "title" "About Me" <> defaultContext)
        >>= relativizeUrls

  match "contact.md" do
    route $ setExtension "html"
    compile $
      customPandoc
        >>= saveSnapshot "content"
        >>= loadAndApplyTemplate "templates/default.html" (constField "title" "Get in Touch" <> defaultContext)
        >>= relativizeUrls

  match "index.html" do
    route idRoute
    compile do
      let posts = take 5 <$> (recentFirst =<< loadAll "posts/*")
      let ctx = listField "posts" defaultContext posts <> constField "title" "Home" <> defaultContext
      getResourceBody
        >>= applyAsTemplate ctx
        >>= loadAndApplyTemplate "templates/default.html" ctx
        >>= relativizeUrls

  match "templates/*" $ compile templateCompiler

  version "redirects" $
    createRedirects
      [
      ]

customPandoc :: Compiler (Item String)
customPandoc = pandocCompilerWithTransform defaultHakyllReaderOptions defaultHakyllWriterOptions (usingSideNotes . usingOldstyleSyntax)

feedConfig :: FeedConfiguration
feedConfig =
  FeedConfiguration
    { feedTitle = "Arusekk blog",
      feedDescription = "IT and unpopular opinions",
      feedAuthorName = "Arusekk",
      feedAuthorEmail = "arek_koz@o2.pl",
      feedRoot = "https://arusekk.github.io"
    }
