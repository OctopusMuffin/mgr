# Praca magisterska
Algorytm do automatycznej segmentacji obrazu utrasonograficznego;
z interfejsem do zliczania powierzchni guza i jego unaczynienia bez konieczności ręcznego obrysowywania jego maski.

Zawiera dwa podejścia do automatycznej segmentacji obrazu z ultrasonografii małych zwierząt: deep-learningowe oraz non-deep-learning. Dane z USG wysokiej rozdzielczości użyte do trenowania i testów uzyskała Agnieszka Drzał (Uniwersytet Jagielloński).

<img width="934" alt="image" src="https://github.com/octpsmon/mgr/assets/78450868/4d4563fa-dbaa-45e4-b34f-1e4c299551e5">

Ryc. 1. GUI z opcją automatycznej i manualnej segmentacji i analizy ilościowej guza.

W „U-Net” znajduje się implementacja konwolucyjnej sieci neuronowej w Pythonie z użyciem biblioteki TensorFlow.

„autosegm_i_ewaluacja” – mieści algorytm oparty o znormalizowane cięcie grafów do wyświetlania autosegmentacji wszystkich przekrojów z pliku dicom w pętli. Stanowi przebudowaną implementację Elawady’ego i współpracowników z 2016 roku.
Program wyjściowy: BUS Segmentation – zestaw funkcji do przetwarzania wstępnego, segmentacji oraz przetwarzania końcowego obrazów z ultrasonografii piersi, wersja 1.0.0.0 (1.08 MB), [Elawady, M., Sadek, I., Shabayek, A. E. R., Pons, G., & Ganau, S. (2016). Automatic nonlinear filtering and segmentation for breast ultrasound images. In Image Analysis and Recognition: 13th International Conference, ICIAR 2016, in Memory of Mohamed Kamel, Póvoa de Varzim, Portugal, July 13-15, 2016, Proceedings 13 (pp. 206-213). Springer International Publishing].

Skrypt ze ścieżki „mgr/autosegm_i_ewaluacja/ultrasound segmentation/iciar2016/mainNC_refactor.m” pozwala pobrać zbiór obrazów wejściowych, zsegmentować je, a na końcu dokonać ilościowej oceny segmentacji, dzięki porównaniu do zbioru referencyjnego z prawdziwymi maskami guza.

„dicom_segmentacja” zawiera skrypt „dicomUSGvol3.m” wraz z instrukcją programu. „dicomUSGvol3.m” to rozszerzenie programu „dicomUSG2vol2.m” [mgr Agnieszka Drzał, WBBiB UJ, Zakład Biofizyki, Pracownia Radiospektroskopii Nowotworów i Radiobiologii], które polega na dodaniu opcji zliczania powierzchni guza i unaczynienia guza bez konieczności ręcznego obrysowywania jego maski.

Skrypty w folderze „autosegm_i_ewaluacja” oraz „dicom_segmentacja” to implementacje w środowisku MATLAB.

![image](https://github.com/octpsmon/mgr/assets/78450868/8d86acbe-911c-446b-afdb-7c875bffa887)
Ryc. 2. Maska guza i ilościowa analiza z automatycznej segmentacji guza w tabeli (segmentacja oparta na znormalizowanym cięciu (Normalized Cut – NC) z dyfuzją anizotropową dla filtrowania plamek (DPAD)).

![image](https://github.com/octpsmon/mgr/assets/78450868/f9d19c5c-5bc7-40b9-bdbf-61fe6cf30fa6)
Ryc. 3. Predykcje U-Net.

![image](https://github.com/octpsmon/mgr/assets/78450868/a9c7a723-1643-4246-a082-2624485803b1)
Ryc. 4. Wyniki z segmentacji opartej na znormalizowanym cięciu (Normalized Cut – NC) z dyfuzją anizotropową dla filtrowania plamek (DPAD). Guzy kolejno od góry: guz 1 na tylnej łapie, guz 2 na tylnej łapie, guz w poduszce tłuszczowej na karku, guz w pakiecie mlecznym.

-------------------------------------------------------------------------------------------------------
Eng. version.
# Master's Thesis
An algorithm for automatic ultrasonographic image segmentation; with an interface for counting tumor area and its vascularization without the need for manually outlining its mask.

Repository includes two approaches to automatic segmentation of ultrasound images from small animals: deep learning and non-deep learning. High-resolution ultrasound data used for training and testing were obtained by Agnieszka Drzał (Jagiellonian University).

<img width="934" alt="image" src="https://github.com/octpsmon/mgr/assets/78450868/4d4563fa-dbaa-45e4-b34f-1e4c299551e5">

Fig. 1. GUI with the option of automatic and manual segmentation and quantitative analysis of the tumor.

In "U-Net," there is an implementation of a convolutional neural network in Python using the TensorFlow library.

"autosegm_i_ewaluacja" – houses an algorithm based on normalized graph cuts for displaying auto-segmentation of all sections from a dicom file in a loop. It is a revamped implementation from Elawady and colleagues from 2016.
Output Program: BUS Segmentation – a set of functions for preprocessing, segmentation, and post-processing of breast ultrasonography images, version 1.0.0.0 (1.08 MB), [Elawady, M., Sadek, I., Shabayek, A. E. R., Pons, G., & Ganau, S. (2016). Automatic nonlinear filtering and segmentation for breast ultrasound images. In Image Analysis and Recognition: 13th International Conference, ICIAR 2016, in Memory of Mohamed Kamel, Póvoa de Varzim, Portugal, July 13-15, 2016, Proceedings 13 (pp. 206-213). Springer International Publishing].

The script from the path "mgr/autosegm_i_ewaluacja/ultrasound segmentation/iciar2016/mainNC_refactor.m" allows downloading a set of input images, segmenting them, and finally conducting a quantitative assessment of the segmentation, by comparing it to a reference set with real tumor masks.

"dicom_segmentacja" contains the script "dicomUSGvol3.m" along with program instructions. "dicomUSGvol3.m" is an extension of the program "dicomUSG2vol2.m" [Agnieszka Drzał, WBBiB UJ, Department of Biophysics, Laboratory of Cancer Radiospectroscopy and Radiobiology], which involves adding the option of counting the tumor area and tumor vascularization without the need for manually outlining its mask.

Scripts in the "autosegm_i_ewaluacja" and "dicom_segmentacja" folders are implementations in the MATLAB environment.

![image](https://github.com/octpsmon/mgr/assets/78450868/8d86acbe-911c-446b-afdb-7c875bffa887)
Fig. 2. Tumor mask and quantitative analysis from automatic tumor segmentation in the table (segmentation based on Normalized Cut (NC) with anisotropic diffusion for speckle filtering (DPAD)).

![image](https://github.com/octpsmon/mgr/assets/78450868/f9d19c5c-5bc7-40b9-bdbf-61fe6cf30fa6)
Fig. 3. U-Net predictions.

![image](https://github.com/octpsmon/mgr/assets/78450868/a9c7a723-1643-4246-a082-2624485803b1)
Fig. 4. Results from segmentation based on Normalized Cut (NC) with Detail Preserving Anosotropic Diffusion for Speckle Filtering (DPAD). Tumors from top: tumor 1 on the rear leg, tumor 2 on the rear leg, tumor in the fat pad on the neck, tumor in the mammary package.
