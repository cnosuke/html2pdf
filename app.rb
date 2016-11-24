require 'sinatra'
require 'pdfkit'

OPTS_PREFIX = 'WKHTMLTOPDF_OPTS_'
WKHTMLTOPDF_OPTS = ENV.select{|k,_| k.start_with?(OPTS_PREFIX) }
   .each_with_object({}) do |(k,v),h|
     h[k.gsub(OPTS_PREFIX, '').downcase.to_sym] = v
   end

puts 'Running with Wkhtmltopdf options:'
p WKHTMLTOPDF_OPTS

if development?
  require 'sinatra/reloader'
  require 'pry'
end

def convert2pdf(url)
  PDFKit.new(url, WKHTMLTOPDF_OPTS).to_pdf
end

def valid_url?(url)
  url && url.match(/^https?\:\/\//) && url.match(URI.regexp)
end

def parse_reqest_url
  request.env['REQUEST_URI'].split('/html2pdf/').last
end

put '/healthcheck' do
  'OK'
end

get '/' do
  'index'
end

get '/revision' do
  open("#{__dir__}/REVISION").read
end

get '/html2pdf/*' do
  request_url = parse_reqest_url
  return 400 unless valid_url?(request_url)

  content_type 'application/pdf'
  return convert2pdf(request_url)
end
