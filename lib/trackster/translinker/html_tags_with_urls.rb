# In the translinker we make all URL's absolute (except '#', mailto: and simple name URLs with refer to the current document)
# As a reference we use the list from  http://stackoverflow.com/questions/2725156/complete-list-of-html-tag-attributes-which-have-a-url-value
#
# That document notes:
#
# <a href=url>
# <applet codebase=url>
# <area href=url>
# <base href=url>
# <blockquote cite=url>
# <body background=url>
# <del cite=url>
# <form action=url>
# <frame longdesc=url> and <frame src=url>
# <head profile=url>
# <iframe longdesc=url> and <iframe src=url>
# <img longdesc=url> and <img src=url> and <img usemap=url>
# <input src=url> and <input usemap=url>
# <ins cite=url>
# <link href=url>
# <object classid=url> and <object codebase=url> and <object data=url> and <object usemap=url>
# <q cite=url>
# <script src=url>
#
# HTML 5 adds a few (and HTML5 seems to not use some of the ones above as well):
# 
# <audio src=url>
# <button formaction=url>
# <command icon=url>
# <embed src=url>
# <html manifest=url>
# <input formaction=url>
# <source src=url>
# <video poster=url> and <video src=url>
#
# These aren't necessarily simple URLs:
# 
# <object archive=url> or <object archive="url1 url2 url3">
# <applet archive=url> or <applet archive=url1,url2,url3>
# <meta http-equiv="refresh" content="seconds; url">
#
module Trackster
  module Translinker
    module HtmlTagsWithUrls
      TAG_URL_ATTRIBUTES = {
        'a'              => 'href',
        'applet'         => 'codebase',
        'area'           => 'href',
        'base'           => 'href',
        'blockquote'     => 'cite',
        'body'           => 'background',
        'del'            => 'cite',
        'form'           => 'action',
        'frame'          => ['src', 'longdesc'],
        'head'           => 'profile',
        'iframe'         => ['src', 'longdesc'],
        'img'            => ['src', 'usemap', 'longdesc'],
        'input'          => 'url',
        'ins'            => 'cite',
        'object'         => ['classid', 'codebase', 'data', 'usemap'],
        'q'              => 'cite',
        'script'         => 'src',
        'audio'          => 'src',
        'button'         => 'formaction',
        'command'        => 'icon',
        'embed'          => 'src',
        'html'           => 'manifest',
        'input'          => 'formaction',
        'source'         => 'src',
        'video'          => ['poster', 'src']
      }
      
      def self.included(base)
        const_set(:TAGS_WITH_URLS, TAG_URL_ATTRIBUTES.to_a.map{|a| a.first})
      end
    end
  end
end