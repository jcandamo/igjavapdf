// ****************************************************************** *'
//  Copyright - Accusoft Corporation, Tampa Florida.                  *'
//  This sample code is provided to Accusoft licensees "as is"        *'
//  with no restrictions on use or modification. No warranty for      *'
//  use of this sample code is provided by Accusoft.                  *'
//                                                                    *'
//  SAMPLE PURPOSE                                                    *'
//                                                                    *'
//  This sample illustrates how to open and save a PDF document.      *'
//                                                                    *'
//                                                                    *'
//  ARGUMENTS                                                         *'
//                                                                    *'
//   First:             The path to source PDF file.                  *'
//   Second (optional): The path to output PDF file.                  *'
//                      (default is <input_file_path>.output.pdf).    *'
//   Third (optional):  The indicator of saving file with             *'
//                      LINEARIZED attribute (default is 'false').    *'
//                                                                    *'
// ****************************************************************** *'

package com.accusoft.samples.OpenSaveSample;

import com.accusoft.imagegearpdf.*;

public class OpenSaveSample
{
    private PDF pdf;
    private Document document;

    static
    {
        System.loadLibrary("IgPdf");
    }

    // Application entry point.
    public static void main(String[] args)
    {
        if (args == null ||
            args.length < 1 ||
            args.length > 3 ||
            args[0].equals("-h") ||
            args[0].equals("--help"))
        {
            printUsage();
            return;
        }

        boolean linearized = false;
        String inputPath = args[0];
        String outputPath;

        if (args.length > 1)
        {
            outputPath = args[1];
        }
        else
        {
            outputPath = inputPath + ".output.pdf";
        }

        if (args.length > 2)
        {
            linearized = Boolean.parseBoolean(args[2]);
        }

        OpenSaveSample sample = new OpenSaveSample();
        sample.loadAndSave(inputPath, outputPath, linearized);
    }

    // Print the sample usage information.
    private static void printUsage()
    {
        System.out.println("Usage:");
        System.out.println("       OpenSaveSample.jar <input_file_path> [<output_file_path> [<save_with_LINEARIZED_flag>]]");
        System.out.println("where:");
        System.out.println("       <input_file_path>:            The path to source PDF file.");
        System.out.println("       <output_file_path>:           The path to output PDF file (default is <input_file_path>.output.pdf).");
        System.out.println("       <save_with_LINEARIZED_flag>:  Indicates that document should be saved with IG_PDF_LINEARIZED flag (default is 'false').");
    }

    // Load and save the PDF file.
    private void loadAndSave(String inputPath, String outputPath, boolean linearized)
    {
        try
        {
            this.initPdf();
            this.openPdf(inputPath);
            this.savePdf(outputPath, linearized);
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

    // Save PDF document to the output path.
    private void savePdf(String outputPath, boolean linearized)
    {
        SaveOptions saveOptions = new SaveOptions();

        // Set LINEARIZED attribute as provided by the user.
        saveOptions.setLinearized(linearized);

        this.document.saveDocument(outputPath, saveOptions);
    }

    // Close the PDF document and terminate the PDF session.
    private void terminatePdf()
    {
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
