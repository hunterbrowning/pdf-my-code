PDFDocument = require("pdfkit")
insist = require("insist-types")
fs = require("fs")
recursive = require("recursive-readdir")

module.exports = (fromPath, toPath) ->
   insist.args(arguments, String, String)
   console.log "fromPath: #{fromPath}"
   console.log "toPath: #{toPath}"

   @pdf = new PDFDocument()

   if fromPath.charAt(0) == "/"
      outgoingName = fromPath.substring(1, fromPath.length)
   else if fromPath.charAt(0) == "~/"
      outgoingName = fromPath.substring(2, fromPath.length)
   else
      outgoingName = fromPath

   @fileStream = fs.createWriteStream("#{toPath}/#{Date.now()}.pdf")
   @pdf.pipe @fileStream

   # Get file paths to work on
   @processedCount = 0
   @fileCount = null
   @quarterProcessed = false
   @halfProcessed = false
   @threeQuarterProcessed = false

   recursive fromPath, (err, files) =>
      @fileCount = files.length
      console.log "Found files: %s", @fileCount
      console.log "Beginning processing..."

      for file in files
         addFileToPdf(file)


addFileToPdf = (filePath) ->
   fs.readFile filePath, 'utf8', (err, data) ->
         # Some process logging for big files
      if !@quarterProcessed and @processedCount/@fileCount >= 0.25
         console.log "1/4 processed" 
         @quarterProcessed = true
      if !@halfProcessed and @processedCount/@fileCount >= 0.5
         console.log "1/2 processed" 
         @halfProcessed = true
      if !@threeQuarterProcessed and @processedCount/@fileCount >= 0.75
         console.log "3/4 processed" 
         @threeQuarterProcessed = true
      @pdf.addPage() unless @processedCount == 0
      @pdf.text(data)
      @processedCount++
      console.log "processing file: #{@processedCount} of #{@fileCount}"
      savePdf() unless @processedCount != @fileCount

savePdf = ->
   console.log "Saving PDF"
   @pdf.end()
