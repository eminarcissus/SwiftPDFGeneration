//
//  AppDelegate.swift
//  SwiftPDFGeneration
//
//  Created by Debasis Das on 01/02/16.
//  Copyright © 2016 Knowstack. All rights reserved.
//

import Cocoa
import Quartz

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    var dataArray:[AnyObject] = []
    
    let columnInformationArray =
    [
        ["columnIdentifier":"col1","columnTitle":"Column Title 1"],
        ["columnIdentifier":"col2","columnTitle":"Column Title 2"],
        ["columnIdentifier":"col3","columnTitle":"Column Title 3"],
        ["columnIdentifier":"col4","columnTitle":"Column Title 4"],
        ["columnIdentifier":"col5","columnTitle":"Column Title 5"],
        ["columnIdentifier":"col6","columnTitle":"Column Title 6"],
        ["columnIdentifier":"col7","columnTitle":"Column Title 7"],
        ["columnIdentifier":"col8","columnTitle":"Column Title 8"],
    ]
    
    func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        self.dataArray = self.createDemoData()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        
    }

    func createDemoData()->Array<AnyObject>{
        let mArray = NSMutableArray()
        
        for i in 0 ..< 800 {
            let dict = [
                "col1":"col 1 data \(i)",
                "col2":"col 2 data \(i)",
                "col3":"col 3 data \(i)",
                "col4":"col 4 data \(i)",
                "col5":"col 5 data \(i)",
                "col6":"col 6 data \(i)",
                "col7":"col 7 data \(i)",
                "col8":"col 8 data \(i)"
            ]
            mArray.add(dict)
        }
        return Array(mArray) as Array<AnyObject>
    }

    @IBAction func generatePDFButton (_ sender:NSButton){

        let savePanel = NSSavePanel()
        
        savePanel.begin { (result: Int) -> Void in
            if result == NSFileHandlingPanelOKButton {
                if let url = savePanel.url {
                    let path = url.path as String
                    self.generatePDF(path + ".pdf")
                }
            }
        }
    }

    @IBAction func generatePDFMustacheButton(_ sender: NSButton) {
        let savePanel = NSSavePanel()
        
        savePanel.begin { (result: Int) -> Void in
            if result == NSFileHandlingPanelOKButton {
                if let url = savePanel.url {
                    let path = url.path as String
                    generateMustachePDF(path + ".pdf")
                }
            }
        }
    }

    func generatePDF (_ pdfLocation: String) -> Void {
        let aPDFDocument = PDFDocument()
        
        let coverPage = CoverPDFPage(hasMargin: true,
                                     title: "This is the cover page title. Keep it short or keep it long",
                                     creditInformation: "Created By: Knowstack.com \r Jan 2016",
                                     headerText: "Some confidential info",
                                     footerText: "www.knowstack.com",
                                     pageWidth: CGFloat(900.0),
                                     pageHeight: CGFloat(1200.0),
                                     hasPageNumber: true,
                                     pageNumber: 1)
        
        
        
        aPDFDocument.insert(coverPage, at: 0)
        
        let pageWidth = (CGFloat(Float(self.columnInformationArray.count)) * defaultColumnWidth) + leftMargin
        let pageHeight = topMargin + verticalPadding + (CGFloat(numberOfRowsPerPage + 1) * defaultRowHeight) + verticalPadding + bottomMargin
        
        
        var numberOfPages = self.dataArray.count / numberOfRowsPerPage
        
        if self.dataArray.count % numberOfRowsPerPage > 0 {
            numberOfPages += 1
        }
        
        for i in 0 ..< numberOfPages
        {
            
            let startIndex = i * numberOfRowsPerPage
            var endIndex = i * numberOfRowsPerPage + numberOfRowsPerPage
            
            if endIndex > self.dataArray.count{
                endIndex = self.dataArray.count
            }
            
            let pdfDataArray:[AnyObject] = Array(self.dataArray[startIndex..<endIndex])
            
            let tabularDataPDF = TabularPDFPage (hasMargin: true,
                                                 headerText: "confidential info...",
                                                 footerText: "www.knowstack.com",
                                                 pageWidth: pageWidth,
                                                 pageHeight: pageHeight,
                                                 hasPageNumber: true,
                                                 pageNumber: i+1,
                                                 pdfData: pdfDataArray,
                                                 columnArray: columnInformationArray as [AnyObject])
            
            aPDFDocument.insert(tabularDataPDF, at: i+1)
        }
        
        aPDFDocument.write(toFile: pdfLocation)
    }
    
    
    
}


class BasePDFPage :PDFPage{
    
    var hasMargin = true
    var headerText = "Default Header Text"
    var footerText = "Default Footer Text"

    var hasPageNumber = true
    var pageNumber = 1
    
    var pdfHeight = CGFloat(1024.0) //This is configurable
    var pdfWidth = CGFloat(768.0)   //This is configurable and is calculated based on the number of columns

    func drawLine( _ fromPoint:NSPoint,  toPoint:NSPoint){
        let path = NSBezierPath()
        NSColor.lightGray.set()
        path.move(to: fromPoint)
        path.line(to: toPoint)
        path.lineWidth = 0.5
        path.stroke()
        
    }
    
    func drawHeader(){
        let headerTextX = leftMargin
        let headerTextY = self.pdfHeight - CGFloat(35.0)
        let headerTextWidth = self.pdfWidth - leftMargin - rightMargin
        let headerTextHeight = CGFloat(20.0)
        
        let headerFont = NSFont(name: "Helvetica", size: 15.0)
        
        let headerParagraphStyle = NSMutableParagraphStyle()
        headerParagraphStyle.alignment = NSRightTextAlignment
        
        let headerFontAttributes = [
            NSFontAttributeName: headerFont ?? NSFont.labelFont(ofSize: 12),
            NSParagraphStyleAttributeName:headerParagraphStyle,
            NSForegroundColorAttributeName:NSColor.lightGray
        ]
        let headerRect = NSMakeRect(headerTextX, headerTextY, headerTextWidth, headerTextHeight)
        self.headerText.draw(in: headerRect, withAttributes: headerFontAttributes)

    }
    
    func drawFooter(){
        let footerTextX = leftMargin
        let footerTextY = CGFloat(15.0)
        let footerTextWidth = self.pdfWidth / 2.1
        let footerTextHeight = CGFloat(20.0)
        
        let footerFont = NSFont(name: "Helvetica", size: 15.0)
        
        let footerParagraphStyle = NSMutableParagraphStyle()
        footerParagraphStyle.alignment = NSLeftTextAlignment
        
        let footerFontAttributes = [
            NSFontAttributeName: footerFont ?? NSFont.labelFont(ofSize: 12),
            NSParagraphStyleAttributeName:footerParagraphStyle,
            NSForegroundColorAttributeName:NSColor.lightGray
        ]
        
        let footerRect = NSMakeRect(footerTextX, footerTextY, footerTextWidth, footerTextHeight)
        self.footerText.draw(in: footerRect, withAttributes: footerFontAttributes)

    }
    
    func drawMargins(){
        let borderLine = NSMakeRect(leftMargin, bottomMargin, self.pdfWidth - leftMargin - rightMargin, self.pdfHeight - topMargin - bottomMargin)
        NSColor.gray.set()
        NSFrameRectWithWidth(borderLine, 0.5)
    }
    
    func drawPageNumbers()
    {
            let pageNumTextX = self.pdfWidth/2
            let pageNumTextY = CGFloat(15.0)
            let pageNumTextWidth = CGFloat(40.0)
            let pageNumTextHeight = CGFloat(20.0)
            
            let pageNumFont = NSFont(name: "Helvetica", size: 15.0)
            
            let pageNumParagraphStyle = NSMutableParagraphStyle()
            pageNumParagraphStyle.alignment = NSCenterTextAlignment
            
            let pageNumFontAttributes = [
                NSFontAttributeName: pageNumFont ?? NSFont.labelFont(ofSize: 12),
                NSParagraphStyleAttributeName:pageNumParagraphStyle,
                NSForegroundColorAttributeName: NSColor.darkGray
            ]
            
            let pageNumRect = NSMakeRect(pageNumTextX, pageNumTextY, pageNumTextWidth, pageNumTextHeight)
            let pageNumberStr = "\(self.pageNumber)"
            pageNumberStr.draw(in: pageNumRect, withAttributes: pageNumFontAttributes)

    }
    
    override func bounds(for box: PDFDisplayBox) -> NSRect
    {
        return NSMakeRect(0, 0, pdfWidth, pdfHeight)
    }

    override func draw(with box: PDFDisplayBox) {
        if hasPageNumber{
            self.drawPageNumbers()
        }
        if hasMargin{
            self.drawMargins()
        }
        if headerText.characters.count > 0 {
            self.drawHeader()
        }
        if footerText.characters.count > 0{
            self.drawFooter()
        }
    }
    
    init(hasMargin:Bool,
        headerText:String,
        footerText:String,
        pageWidth:CGFloat,
        pageHeight:CGFloat,
        hasPageNumber:Bool,
        pageNumber:Int)
    {
     super.init()
        self.hasMargin = hasMargin
        self.headerText = headerText
        self.footerText = footerText
        self.pdfWidth = pageWidth
        self.pdfHeight = pageHeight
        self.hasPageNumber = hasPageNumber
        self.pageNumber = pageNumber
    }
    
}

class CoverPDFPage: BasePDFPage{
    var pdfTitle:NSString = "Default PDF Title"
    var creditInformation = "Default Credit Information"

    init(hasMargin:Bool,
        title:String,
        creditInformation:String,
        headerText:String,
        footerText:String,
        pageWidth:CGFloat,
        pageHeight:CGFloat,
        hasPageNumber:Bool,
        pageNumber:Int)
    {
        super.init(hasMargin: hasMargin,
            headerText: headerText,
            footerText: footerText,
            pageWidth: pageWidth,
            pageHeight: pageHeight,
            hasPageNumber: hasPageNumber,
            pageNumber: pageNumber)
        
        self.pdfTitle = title as NSString
        self.creditInformation = creditInformation
    }

    func drawPDFTitle()
    {
        let pdfTitleX = 1/4 * self.pdfWidth
        let pdfTitleY = self.pdfHeight / 2
        let pdfTitleWidth = 1/2 * self.pdfWidth
        let pdfTitleHeight = 1/5 * self.pdfHeight
        let titleFont = NSFont(name: "Helvetica Bold", size: 30.0)
        
        let titleParagraphStyle = NSMutableParagraphStyle()
        titleParagraphStyle.alignment = NSCenterTextAlignment
        
        let titleFontAttributes = [
            NSFontAttributeName: titleFont ?? NSFont.labelFont(ofSize: 12),
            NSParagraphStyleAttributeName:titleParagraphStyle,
            NSForegroundColorAttributeName: NSColor.blue
        ]
        
        let titleRect = NSMakeRect(pdfTitleX, pdfTitleY, pdfTitleWidth, pdfTitleHeight)
        self.pdfTitle.draw(in: titleRect, withAttributes: titleFontAttributes)
        
    }
    
    func drawPDFCreditInformation()
    {
        let pdfCreditX = 1/4 * self.pdfWidth
        let pdfCreditY = self.pdfHeight / 2 - 1/5 * self.pdfHeight
        let pdfCreditWidth = 1/2 * self.pdfWidth
        let pdfCreditHeight = CGFloat(40.0)
        let creditFont = NSFont(name: "Helvetica", size: 15.0)
        
        let creditParagraphStyle = NSMutableParagraphStyle()
        creditParagraphStyle.alignment = NSCenterTextAlignment
        
        let creditFontAttributes = [
            NSFontAttributeName: creditFont ?? NSFont.labelFont(ofSize: 12),
            NSParagraphStyleAttributeName:creditParagraphStyle,
            NSForegroundColorAttributeName: NSColor.darkGray
        ]
        
        let creditRect = NSMakeRect(pdfCreditX, pdfCreditY, pdfCreditWidth, pdfCreditHeight)
        self.creditInformation.draw(in: creditRect, withAttributes: creditFontAttributes)

    }
    
    override func draw(with box: PDFDisplayBox) {
        super.draw(with: box)
        self.drawPDFTitle()
        self.drawPDFCreditInformation()
    }

}

class TabularPDFPage: BasePDFPage{
    var dataArray : [AnyObject] = []
    var columnsArray : [AnyObject] = []
    var verticalPadding = CGFloat(10.0)
    
    init(hasMargin:Bool,
        headerText:String,
        footerText:String,
        pageWidth:CGFloat,
        pageHeight:CGFloat,
        hasPageNumber:Bool,
        pageNumber:Int,
        pdfData:[AnyObject],
        columnArray:[AnyObject])
    {
        super.init(hasMargin: hasMargin,
            headerText: headerText,
            footerText: footerText,
            pageWidth: pageWidth,
            pageHeight: pageHeight,
            hasPageNumber: hasPageNumber,
            pageNumber: pageNumber
        )
        self.dataArray = pdfData
        self.columnsArray = columnArray

    }

    func drawTableData(){
        
        
        //If draws column title = YES
        let titleFont = NSFont(name: "Helvetica Bold", size: 14.0)
        
        let titleParagraphStyle = NSMutableParagraphStyle()
        titleParagraphStyle.alignment = NSCenterTextAlignment
        
        let titleFontAttributes = [
            NSFontAttributeName: titleFont ?? NSFont.labelFont(ofSize: 12),
            NSParagraphStyleAttributeName:titleParagraphStyle,
            NSForegroundColorAttributeName: NSColor.gray
        ]
        
        for i in 0  ..< self.columnsArray.count {
            let columnHeader = self.columnsArray[i]
            let columnTitle = columnHeader["columnTitle"] as! NSString
            let headerRect = NSMakeRect(
                leftMargin + (CGFloat(i) * defaultColumnWidth),
                self.pdfHeight - topMargin - verticalPadding - defaultRowHeight,
                defaultColumnWidth,
                defaultRowHeight)
            
            columnTitle.draw(in: headerRect, withAttributes: titleFontAttributes)
            
        }
        
        let keys = NSMutableArray()
        for columnInfo in self.columnsArray{
            keys.add(columnInfo["columnIdentifier"] as! String)
            
        }
        
        for i in 0  ..< self.dataArray.count
        {
            let dataDict = self.dataArray[i]
            
            for j in 0  ..< keys.count {
                let dataText = dataDict[keys[j] as! String] as! NSString
                let dataRect = NSMakeRect(
                    leftMargin + textInset + (CGFloat(j) * defaultColumnWidth),
                    self.pdfHeight - topMargin - verticalPadding - (2 * defaultRowHeight) - textInset - (CGFloat(i) * defaultRowHeight),
                    defaultColumnWidth,
                    defaultRowHeight
                )
                dataText.draw(in: dataRect, withAttributes: nil)
            }
        }

    }
    
    func drawVerticalGrids(){
        
        for i in 0 ..< self.columnsArray.count {
            
            //draw the vertical lines
            let fromPoint = NSMakePoint(
                leftMargin + (CGFloat(i) * defaultColumnWidth),
                self.pdfHeight - topMargin )

            let toPoint = NSMakePoint(
                leftMargin  + (CGFloat(i) * defaultColumnWidth),
                bottomMargin
                //self.pdfHeight - (CGFloat(self.dataArray.count + 2) * defaultRowHeight) - topMargin
            )

            drawLine(fromPoint, toPoint: toPoint)
        }
    }
    
    func drawHorizontalGrids(){
        let rowCount = self.dataArray.count
        for i in 0 ..< rowCount {
            let fromPoint = NSMakePoint(
                leftMargin ,
                self.pdfHeight - topMargin - verticalPadding - defaultRowHeight - (CGFloat(i) * defaultRowHeight)
            )
            let toPoint = NSMakePoint(self.pdfWidth - rightMargin,
                self.pdfHeight - topMargin - verticalPadding - defaultRowHeight - (CGFloat(i) * defaultRowHeight)
            )
            drawLine(fromPoint, toPoint: toPoint)
        }

    }
    
    override func draw(with box: PDFDisplayBox) {
        super.draw(with: box)
        self.drawTableData()
        self.drawVerticalGrids()
        self.drawHorizontalGrids()
    }

    
}
