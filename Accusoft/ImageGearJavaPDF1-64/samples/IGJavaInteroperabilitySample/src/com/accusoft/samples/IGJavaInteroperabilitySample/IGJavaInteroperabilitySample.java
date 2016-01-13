// ******************************************************************** *'
//  Copyright - Accusoft Corporation, Tampa Florida.                    *'
//  This sample code is provided to Accusoft licensees "as is"          *'
//  with no restrictions on use or modification. No warranty for        *'
//  use of this sample code is provided by Accusoft.                    *'
//                                                                      *'
//  SAMPLE PURPOSE                                                      *'
//                                                                      *'
//  This sample illustrates how to add an image to a new PDF document.  *'
//  This sample uses both ImageGearJava and ImageGearJavaPDF libraries. *'
//                                                                      *'
//  ARGUMENTS                                                           *'
//                                                                      *'
//   First:              The path to source image file.                 *'
//   Second (optional):  The path to output PDF file.                   *'
//                                                                      *'
// ******************************************************************** *'

package com.accusoft.samples.IGJavaInteroperabilitySample;

import com.accusoft.imagegearpdf.*;

import com.accusoft.imagegear.core.*;
import com.accusoft.imagegear.formats.*;

import java.awt.image.BufferedImage;
import java.io.IOException;
import javax.imageio.ImageIO;
import java.io.*;

public class IGJavaInteroperabilitySample
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
            args.length > 2 ||
            args[0].equals("-h") ||
            args[0].equals("--help"))
        {
            printUsage();
            return;
        }

        String inputPath = null;
        String outputPath = null;

        inputPath = args[0];
        if (args.length > 1)
        {
            outputPath = args[1];
        }
        else
        {
            outputPath = inputPath + ".pdf";
        }

        IGJavaInteroperabilitySample sample = new IGJavaInteroperabilitySample();
        sample.addImageToPdf(inputPath, outputPath);
    }

    // Print the sample usage information.
    private static void printUsage()
    {
        System.out.println("Usage:");
        System.out.println("       IGJavaInteroperabilitySample.jar <input_file_path> [<output_file_path>]");
        System.out.println("where:");
        System.out.println("       <input_file_path>:       The path to source image file.");
        System.out.println("       <output_file_path>:      The path to output PDF file.");
    }

    // Read an image file and save it to PDF. Using ImageGearJava and ImageGearJavaPDF libraries.
    private void addImageToPdf(String inputPath, String outputPath)
    {
        try
        {
            // Read image from file to a BufferedImage.
            BufferedImage bufferedImage = this.getImage(inputPath);

            // Convert BufferedImage to byte array.
            ByteArrayOutputStream byteArrayStream = new ByteArrayOutputStream();
            ImageIO.write(bufferedImage, "bmp", byteArrayStream);
            byte[] imageData = byteArrayStream.toByteArray();
            byteArrayStream.close();

            // Add image to PDF document.
            this.saveImage(outputPath, imageData);
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

    // Get image file asbyte array of the image. Using ImageGearJava library.
    private BufferedImage getImage(String inputPath) throws IOException
    {
        // Set evaluation license info;
        // NOTE: The following five lines are using for evaluation license only.
        // They should be commented to set the deployment license.
        ImGearEvaluationManager.initialize();
        if((System.getProperty("os.arch").contains("64")))
            ImGearLicense.setSolutionName("AccuSoft 21-33-2");
        else
            ImGearLicense.setSolutionName("AccuSoft 21-32-2");

        // Set license info.
        // NOTE: The following three lines should be uncommented and modified using the corresponding license.
        //ImGearLicense.setSolutionName("Your Solution Name");
        //ImGearLicense.setSolutionKey(12345, 12345, 12345, 12345);
        //ImGearLicense.setOEMLicenseKey("1.0.AStringForOEMLicensingContactAccusoftSalesForMoreInformation...");

        // Initialize common formats.
        ImGearCommonFormats.initialize();

        // Read the image file.
        ImGearStream imageStream = ImGearStreams.fileStream(inputPath, "r");
        ImGearPage imagePage = ImGearFileFormats.loadPage(imageStream, 0, null);
        imageStream.close();
        BufferedImage bufferedImage = ImGearFileFormats.exportToImage(imagePage);

        return bufferedImage;
    }

    // Save the image as a PDF document. Using ImageGearJavaPDF library.
    private void saveImage(String outputPath, byte[] byteArray) throws IOException
    {
        this.pdf = PDF.getInstance();

        // Set license info.
        // NOTE: The following three lines should be uncommented and modified using the corresponding license.
        // pdf.setSolutionName("YourSolutionName");
        // pdf.setSolutionKey(0x00000000,0x00000000,0x00000000,0x00000000);
        // pdf.setOEMLicenseKey("YourOEMLicenseKey");

        // Only initialize the PDF session after setting any licensing information is provided.
        this.pdf.initialize();

        // Create PDF document with a single page.
        this.document = this.pdf.createDocument();
        this.document.insertBlankPage(0);

        // Get the first page to add the image.
        this.page = this.document.getPage(0);

        // Create default options to add an image.
        AddImageOptions options = new AddImageOptions();

        // Add the image to PDF page.
        this.page.addImage(byteArray, options);

        // Create default options to save PDF document.
        SaveOptions saveOptions = new SaveOptions();
        this.document.saveDocument(outputPath, saveOptions);
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
