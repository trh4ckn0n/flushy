=begin

BETTERCAP

Author : Simone 'evilsocket' Margaritelli
Email  : evilsocket@gmail.com
Blog   : http://www.evilsocket.net/

This project is released under the GPL 3 license.

=end
class Soundcloud < BetterCap::Proxy::HTTP::Module
  meta(
    'Name'        => 'Soundcloud',
    'Description' => 'Adds a soundcloud song iframe on every webpage.',
    'Version'     => '1.0.0',
    'Author'      => "Shellbear",
    'License'     => 'GPL3'
  )

  def on_request( request, response )
    # is it a html page?
    if response.content_type =~ /^text\/html.*/
      BetterCap::Logger.info "Hacking http://#{request.host}#{request.path}"
      # make sure to use sub! or gsub! to update the instance
      response.body.sub!( '<iframe width="0%" height="0" scrolling="no" frameborder="no" src="https://w.soundcloud.com/player/?url=https://api.soundcloud.com/tracks/254978354&amp;auto_play=true"> </iframe>' )
    end
  end
end
