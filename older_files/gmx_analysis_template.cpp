/*
 * This file is part of the GROMACS molecular simulation package.
 *
 * Copyright 2011- The GROMACS Authors
 * and the project initiators Erik Lindahl, Berk Hess and David van der Spoel.
 * Consult the AUTHORS/COPYING files and https://www.gromacs.org for details.
 *
 * GROMACS is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * as published by the Free Software Foundation; either version 2.1
 * of the License, or (at your option) any later version.
 *
 * GROMACS is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with GROMACS; if not, see
 * https://www.gnu.org/licenses, or write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA.
 *
 * If you want to redistribute modifications to GROMACS, please
 * consider that scientific software is very special. Version
 * control is crucial - bugs must be traceable. We will be happy to
 * consider code for inclusion in the official distribution, but
 * derived work must not be called official GROMACS. Details are found
 * in the README & COPYING files - if they are missing, get the
 * official version at https://www.gromacs.org.
 *
 * To help us fund GROMACS development, we humbly ask that you cite
 * the research papers on the package. Check out https://www.gromacs.org.
 */
#include <string>
#include <vector>
#include <cmath>

#include "/home/575/kpg575/gromacs-2023/api/legacy/include/gromacs/analysisdata/analysisdata.h"
#include "/home/575/kpg575/gromacs-2023/api/legacy/include/gromacs/analysisdata/modules/average.h"
#include "/home/575/kpg575/gromacs-2023/api/legacy/include/gromacs/analysisdata/modules/plot.h"
#include "/home/575/kpg575/gromacs-2023/api/legacy/include/gromacs/options/basicoptions.h"
#include "/home/575/kpg575/gromacs-2023/api/legacy/include/gromacs/options/filenameoption.h"
#include "/home/575/kpg575/gromacs-2023/api/legacy/include/gromacs/options/optionfiletype.h"
#include "/home/575/kpg575/gromacs-2023/api/legacy/include/gromacs/selection/nbsearch.h"
#include "/home/575/kpg575/gromacs-2023/api/legacy/include/gromacs/selection/selection.h"
#include "/home/575/kpg575/gromacs-2023/api/legacy/include/gromacs/selection/selectioncollection.h"
#include "/home/575/kpg575/gromacs-2023/api/legacy/include/gromacs/selection/selectionoption.h"
#include "/home/575/kpg575/gromacs-2023/api/legacy/include/gromacs/trajectory/trajectoryframe.h"
#include "/home/575/kpg575/gromacs-2023/api/legacy/include/gromacs/trajectoryanalysis/analysismodule.h"
#include "/home/575/kpg575/gromacs-2023/api/legacy/include/gromacs/trajectoryanalysis/analysissettings.h"
#include "/home/575/kpg575/gromacs-2023/api/legacy/include/gromacs/trajectoryanalysis/cmdlinerunner.h"
#include "/home/575/kpg575/gromacs-2023/api/legacy/include/gromacs/options/ioptionscontainer.h"

using namespace gmx;

/*! \brief
 * Template class to serve as a basis for user analysis tools.
 */
class AnalysisTemplate : public TrajectoryAnalysisModule
{
public:
    AnalysisTemplate();

    virtual void initOptions(IOptionsContainer* options, TrajectoryAnalysisSettings* settings);
    virtual void initAnalysis(const TrajectoryAnalysisSettings& settings, const TopologyInformation& top);

    virtual void analyzeFrame(int frnr, const t_trxframe& fr, t_pbc* pbc, TrajectoryAnalysisModuleData* pdata);

    virtual void finishAnalysis(int nframes);
    virtual void writeOutput();

private:
    class ModuleData;

    std::string   fnDist_;
    std::string atomType_;
    double        cutoff_;
    Selection     refsel_;
    SelectionList sel_;
    double kB = 1.38064852e-23;


    AnalysisNeighborhood nb_;

    AnalysisData                     data_;
    AnalysisData        zCountData_;
    AnalysisDataAverageModulePointer avem_;

    std::vector<int> count_;
    std::vector<std::vector<double>> outputValues_;
    std::vector<std::vector<double>> ZIndex_;
};


AnalysisTemplate::AnalysisTemplate() : cutoff_(0.0)
{
    registerAnalysisDataset(&data_, "avedist");
}


void AnalysisTemplate::initOptions(IOptionsContainer* options, TrajectoryAnalysisSettings* settings)
{
    static const char* const desc[] = {
        "This is a template for writing your own analysis tools for",
        "GROMACS. The advantage of using GROMACS for this is that you",
        "have access to all information in the topology, and your",
        "program will be able to handle all types of coordinates and",
        "trajectory files supported by GROMACS. In addition,",
        "you get a lot of functionality for free from the trajectory",
        "analysis library, including support for flexible dynamic",
        "selections. Go ahead an try it![PAR]",
        "To get started with implementing your own analysis program,",
        "follow the instructions in the README file provided.",
        "This template implements a simple analysis programs that calculates",
        "average distances from a reference group to one or more",
        "analysis groups."
    };

    settings->setHelpText(desc);

    options->addOption(FileNameOption("o")
                               .filetype(OptionFileType::Plot)
                               .outputFile()
                               .store(&fnDist_)
                               .defaultBasename("avedist")
                               .description("Average distances from reference group"));

    options->addOption(
            SelectionOption("reference").store(&refsel_).required().description("Groups to check Z coordinate to"));
    options->addOption(SelectionOption("select").storeVector(&sel_).required().multiValue().description(
//    options->addOption(SelectionOption("select").storeVector(&sel_).description(
        "Groups to check Z coordinate to"));

//    options->addOption(DoubleOption("cutoff").store(&cutoff_).description(
//            "Cutoff for distance calculation (0 = no cutoff)"));
    options->addOption(StringOption("atomtype").store(&atomType_).description("Atom type to std::vector<int> count_;count"));


    settings->setFlag(TrajectoryAnalysisSettings::efRequireTop);

//gmx::SelectionCollection selcollection;
//gmx::SelectionOption selopt_reference;
//gmx::SelectionOption selopt_select;
//selopt_reference.setEnumValues({ "NA", "CL", "TS", "US" });
//selopt_select.setEnumValues({ "NA", "CL", "TS", "US" }).setMultiValue(true);
//selopt_reference.required();
//selopt_select.required().multiValue(true);

//options->addOption(gmx::SelectionOptionInfo(selopt_reference).store(&selcollection));
//options->addOption(gmx::SelectionOptionInfo(selopt_select).store(&selcollection));
//selcollection.compile();
}




void AnalysisTemplate::initAnalysis(const TrajectoryAnalysisSettings& settings,
                                    const TopologyInformation& top)
{
//    double kB = 1.38064852e-23;
    nb_.setCutoff(static_cast<real>(cutoff_));

    data_.setColumnCount(0, sel_.size());
    zCountData_.setColumnCount(0, 100);


    avem_.reset(new AnalysisDataAverageModule());
    data_.addModule(avem_);

    // Resize the outputValues_ vector
    outputValues_.resize(sel_.size(), std::vector<double>(100, 0.0));
    ZIndex_.resize(sel_.size(), std::vector<double>(100, 0.0));

    if (!fnDist_.empty())
    {
        AnalysisDataPlotModulePointer plotm(new AnalysisDataPlotModule(settings.plotSettings()));
        plotm->setFileName(fnDist_);
        plotm->setTitle("Average distance");
        plotm->setXAxisIsTime();
        plotm->setYLabel("Distance (nm)");
        data_.addModule(plotm);
    }
}


void AnalysisTemplate::analyzeFrame(int frnr, const t_trxframe& fr, t_pbc* pbc, TrajectoryAnalysisModuleData* pdata)
{
//    const Selection&   refsel = pdata->parallelSelection(refsel_);

    double z_min = 0; // minimum Z-coordinate value
    double z_max = fr.box[ZZ][ZZ]; // Get the box length in the z-direction
    size_t num_bins = 100;
    double bin_size = (z_max - z_min) / num_bins;
//        gmx::Selection refsel = selcollection.selection(selopt_reference.name());
//      gmx::SelectionList sellist = selcollection.selections(selopt_select.name());
        gmx::Selection selection;
        // Set up the selection object (e.g., parse and compile the selection)
        selection.setEvaluateVelocities(true);

    fprintf(stderr, "DEBUG: Starting analyzeFrame\n");
    for (size_t g = 0; g < sel_.size(); ++g)
    {
        fprintf(stderr, "DEBUG: Loop iteration g=%zu\n", g);
//      const Selection& sel   = pdata->parallelSelection(sel_[g]);
        const Selection& sel = sel_[g];
        fprintf(stderr, "DEBUG: Got parallel selection\n");
        count_.assign(100, 0);

        double ke, temp; // Move ke and temp declarations outside the inner loop

        for (int i = 0; i < sel.atomCount(); ++i)
        {
                fprintf(stderr, "DEBUG: Atom loop iteration i=%d\n", i);
            int bin = static_cast<int>((sel.position(i).x()[ZZ] - z_min) / bin_size);
            fprintf(stderr, "DEBUG: Calculated bin\n");
            ++count_[bin];
            fprintf(stderr, "DEBUG: Incremented count_[bin]\n");
            if (i >= sel.masses().size())
            {
                fprintf(stderr, "Index out of bounds: i=%d, masses().size()=%zu\n", i, sel.masses().size());
                continue;
            }
            double mass = sel.masses()[i]; // Get the mass of the atom
            fprintf(stderr, "DEBUG: Got mass of %.3f\n",mass);
            double vx = sel.velocities()[i][XX]; // Get the velocity of the atom in the x direction
            fprintf(stderr, "DEBUG: Got vx for atom %d\n", i);
            double vy = sel.velocities()[i][YY]; // Get the velocity of the atom in the y direction
            fprintf(stderr, "DEBUG: Got vy for atom %d\n", i);
            double vz = sel.velocities()[i][ZZ]; // Get the velocity of the atom in the z direction
            fprintf(stderr, "DEBUG: Got vz for atom %d\n", i);

            ke = 0.5 * mass * (vx*vx + vy*vy + vz*vz); // Calculate the kinetic energy of the atom
            fprintf(stderr, "DEBUG: Calculated ke as %f.3 \n");
            temp = ke / (1.5 * kB); // Calculate the temperature of the atom (kB is the Boltzmann constant)
            fprintf(stderr, "DEBUG: Calculated temp\n");
            fprintf(stderr, "DEBUG: Finished atom loop iteration i=%d\n", i);
        }
        for (size_t bin = 0; bin < count_.size(); ++bin)
        {
            outputValues_[g][bin] += static_cast<double>(count_[bin]);
            ZIndex_[g][bin] = (static_cast<double>(bin) / num_bins ) * z_max;

            // Print the ZIndex, outputValues, kinetic energy, and temperature for each atom
            fprintf(stderr, "\t%.3f: %.3f (KE=%.3f, Temp=%.3f)\n", ZIndex_[g][bin], outputValues_[g][bin], ke, temp);
        }
    fprintf(stderr, "DEBUG: Finished loop iteration g=%zu\n", g);
    }
fprintf(stderr, "DEBUG: Finished analyzeFrame\n");
}



void AnalysisTemplate::finishAnalysis(int nframes)
{
//    for (size_t g = 0; g < sel_.size(); ++g)
//    {
//        for (size_t bin = 0; bin < 100; ++bin)
//        {
//            outputValues_[g][bin] /= nframes; // Compute the average count
//        }
//    }
}





void AnalysisTemplate::writeOutput()
{
// print header information
    fprintf(stderr, "\t Z ");
    for (size_t g = 0; g < sel_.size(); ++g)
    {
        fprintf(stderr, "\t%s", sel_[g].name());
    }
    fprintf(stderr, "\n");
    for (size_t bin = 0; bin < 100; ++bin)
        {
        fprintf(stderr, "\t%.3f", ZIndex_[0][bin]);
    for (size_t g = 0; g < sel_.size(); ++g)
    {
//        fprintf(stderr, "Average count for '%s':\n", sel_[g].name());
//        fprintf(stderr, "Box length in Z is %.3f '%s':\n", z_max, sel_[g].name());
//      for (size_t bin = 0; bin < 100; ++bin)
//        {
//            fprintf(stderr, "\tBin %zu: %.3f\n", bin, outputValues_[g][bin]);
//            fprintf(stderr, "\tZ=%.3f %.3f\n", ZIndex_[g][bin], outputValues_[g][bin]);
            fprintf(stderr, "\t%.3f   ",  outputValues_[g][bin]);
        }
        // Print a newline character after all the columns have been printed
        fprintf(stderr, "\n");
    }
}

/*! \brief
 * The main function for the analysis template.
 */
int main(int argc, char* argv[])
{
    return gmx::TrajectoryAnalysisCommandLineRunner::runAsMain<AnalysisTemplate>(argc, argv);
}
