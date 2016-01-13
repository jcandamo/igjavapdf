// ******************************************************************** *'
//  Copyright - Accusoft Corporation, Tampa Florida.                    *'
//  This sample code is provided to Accusoft licensees "as is"          *'
//  with no restrictions on use or modification. No warranty for        *'
//  use of this sample code is provided by Accusoft.                    *'
//                                                                      *'
//  SAMPLE PURPOSE                                                      *'
//                                                                      *'
//  This sample illustrates how to open and render a PDF document       *'
//  to a BufferedImage.                                                 *'
//                                                                      *'
//                                                                      *'
//  ARGUMENTS                                                           *'
//                                                                      *'
//   First:             The path to source PDF file.                    *'
//   Second (optional): The page number (zero-based) of the             *'
//                      PDF document to render (default is 0).          *'
//   Third (optional):  The path to output image file                   *'
//                      (default is <input_file_path>.png).             *'
//   Fourth (optional): The resolution for PDF page rasterization       *'
//                      (default is 150.0).                             *'
//   Fifth (optional):  The smoothing flags for PDF page rasterization  *'
//                      (default is 1).                                 *'
//                                                                      *'
// ******************************************************************** *'

package com.accusoft.samples.RenderSample;

import com.accusoft.imagegearpdf.*;

import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import javax.imageio.ImageIO;
import java.io.*;

public class RenderSample
{
    private PDF pdf;
    private Document document;
    private Page page;

    static
    {
        System.loadLibrary("IgPdf");
    }

    // Application entry point.
    public static void main(String[] args)
    {
        if (args == null ||
            args.length < 1 ||
            args.length > 5 ||
            args[0].equals("-h") ||
            args[0].equals("--help"))
        {
            printUsage();
            return;
        }

        String inputPath = null;
        int pageNumber = 0;
        String outputPath = null;
        double resolution = 0.0;
        int smoothingFlags = -1;

        try
        {
            inputPath = args[0];
            if (args.length > 1)
            {
                pageNumber = Integer.parseInt(args[1]);
            }

            if (args.length > 2)
            {
                outputPath = args[2];
            }
            else
            {
                outputPath = inputPath + ".png";
            }
        }
        catch (NumberFormatException ex)
        {
            System.err.println("The page number must be an integer, not '" + args[1] + "'.");
            return;
        }

        try
        {
            if (args.length > 3)
            {
                resolution = Double.parseDouble(args[3]);
                if (resolution < 1)
                {
                    resolution = -1;
                }
            }
        }
        catch (NumberFormatException ex)
        {
            // This is checked below.
            resolution = -1.0;
        }

        if (resolution < 0)
        {
            System.err.println("The resolution must be a positive fractional number (not less than 1), not '" + args[3] + "'.");
            return;
        }

        try
        {
            if (args.length > 4)
            {
                smoothingFlags = Integer.parseInt(args[4]);
            }
        }
        catch (NumberFormatException ex)
        {
            System.err.println("The smoothing flags must be an integer, not '" + args[4] + "'.");
            return;
        }

        RenderSample sample = new RenderSample();
        sample.performRender(inputPath, pageNumber, outputPath, resolution, smoothingFlags);
    }

    // Print the sample usage information.
    private static void printUsage()
    {
        System.out.println("Usage:");
        System.out.println("       RenderSample.jar <input_file_path> [<page_number> [<output_file_path> [<resolution> [<smoothing_flags>]]]]");
        System.out.println("where:");
        System.out.println("       <input_file_path>:   The path to source PDF file.");
        System.out.println("       <page_number>:       The page number in the PDF file to render (default is 0).");
        System.out.println("       <output_file_path>:  The path to output PNG file (default is <input_file_path>.png).");
        System.out.println("       <resolution>:        The resolution in dots per inch for PDF page rasterization (default is 150.0).");
        System.out.println("       <smoothing_flags>:   The smoothing flags for PDF page rasterization (default is 1).");
    }

    private void performRender(String inputPath, int pageNumber, String outputPath, double resolution, int smoothingFlags)
    {
        try
        {
            this.initPdf();
            this.openPdf(inputPath);
            this.renderPage(pageNumber, outputPath, resolution, smoothingFlags);
        }
        catch (IOException ex)
        {
            System.err.println("IOException: " + ex.toString());
        }
        catch (Throwable ex)
        {
            System.err.println("Exception: " + ex.toString());
        }
        finally
        {
            this.terminatePdf();
        }
    }

    // Initialize the PDF session.
    private void initPdf()
    {
        this.pdf = PDF.getInstance();

        // Set license info.
        // NOTE: The following three lines should be uncommented and modified using the corresponding license.
        // pdf.setSolutionName("YourSolutionName");
        // pdf.setSolutionKey(0x00000000,0x00000000,0x00000000,0x00000000);
        // pdf.setOEMLicenseKey("YourOEMLicenseKey");

        // Only initialize the PDF session after setting any licensing information is provided.
        this.pdf.initialize();
    }

    // Open input PDF document.
    private void openPdf(String inputPath)
    {
        this.document = this.pdf.createDocument();
        this.document.openDocument(inputPath);
    }

    // Render page of PDF document.
    private void renderPage(int pageNumber, String outputPath, double resolution, int smoothingFlags) throws IOException
    {
        // Get the page to render.
        this.page = this.document.getPage(pageNumber);

        // Render the page to a BufferedImage object.
        RenderOptions options = new RenderOptions();
        if (resolution > 0)
        {
            options.setResolution(resolution);
        }

        if (smoothingFlags >= 0)
        {
            options.setSmoothingFlags(smoothingFlags);
        }

        ByteArrayInputStream imageData = new ByteArrayInputStream(this.page.render(options));
        BufferedImage bufferedImage = ImageIO.read(imageData);

        // Write the BufferedImage object to the output image file.
        File outputFile = new File(outputPath);
        ImageIO.write(bufferedImage, "png", outputFile);
    }

    // Close the PDF page, document and terminate the PDF session.
    private void terminatePdf()
    {
        if (this.page != null)
        {
            this.page.close();
            this.page = null;
        }

        if (this.document != null)
        {
            this.document.close();
            this.document = null;
        }

        if (this.pdf != null)
        {
            this.pdf.terminate();
            this.pdf = null;
        }
    }
}
