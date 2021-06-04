# mgr
Algorytm do automatycznej segmentacji obrazu utrasonograficznego

Zawiera dwa podejścia do automatycznej segmentacji obrazu z USG wysokiej rozdzielczości do obrazowania żywych myszy in vivo.

W „U-Net” znajduje się implementacja konwolucyjnej sieci neuronowej w Pythonie z użyciem biblioteki TensorFlow.

„autosegm_i_ewaluacja” – mieści algorytm oparty o znormalizowane cięcie grafów do wyświetlania autosegmentacji wszystkich przekrojów z pliku dicom w pętli. Stanowi przebudowaną implementację Elawady’ego i współpracowników z 2016 roku.
Program wyjściowy: BUS Segmentation – zestaw funkcji do przetwarzania wstępnego, segmentacji oraz przetwarzania końcowego obrazów z ultrasonografii piersi, wersja 1.0.0.0 (1.08 MB), [Elawady et al., 2016]. Artykuł: Elawady, M., Sadek, I., Shabayek, AER, Pons, G., Ganau, S. (2016). Automatic Nonlinear Filtering and Segmentation for Breast Ultrasound Images. Campilho A & Karray F (eds.) W: Image Analysis and Recognition. ICIAR 2016. Lecture Notes in Computer Science, 9730. ICIAR 2016: International Conference on Image Analysis and Recognition, Póvoa de Varzim, Portugal, 13.07.2016-15.07.2016. Cham, Switzerland: Springer International Publishing, pp. 206-213. https://doi.org/10.1007/978-3-319-41501-7_24.

Skrypt ze ścieżki „mgr/autosegm_i_ewaluacja/ultrasound segmentation/iciar2016/mainNC_refactor.m” pozwala pobrać zbiór obrazów wejściowych, zsegmentować je, a na końcu dokonać ilościowej oceny segmentacji, dzięki porównaniu do zbioru referencyjnego z prawdziwymi maskami guza.

„dicom_segmentacja” zawiera skrypt „dicomUSGvol3.m” wraz z instrukcją programu. „dicomUSGvol3.m” to rozszerzenie programu „dicomUSG2vol2.m”, które polega na dodaniu opcji zliczania powierzchni guza i unaczynienia guza bez konieczności ręcznego obrysowywania jego maski.

Skrypty w folderze „autosegm_i_ewaluacja” oraz „dicom_segmentacja” to implementacje w środowisku MATLAB.

