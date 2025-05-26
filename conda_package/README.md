# OpeMM Feedstock by Acellera

This is a partial fork of the conda-forge feedstock for OpenMM.
The idea is to be able to quickly create OpenMM release candidates from specific commits without having to wait for an official OpenMM release.

To create a new release you need to:

1. Open the recipe/meta.yaml file and change the package version at the top of the file.
2. Update the git_rev version in the meta.yaml file in the source section to point to the desired commit.
3. Push your changes
