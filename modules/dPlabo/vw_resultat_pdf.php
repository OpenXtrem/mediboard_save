<?php

/**
 *	@package Mediboard
 *	@subpackage dPlabo
 *	@version $Revision: $
 *  @author Alexis Granger
 */

global $dPconfig, $g, $uistyle;

// Recuperation de l'id de la prescription
$prescription_id = mbGetValueFromGet("prescription_id");

// Chargement de la prescription selectionn�e
$prescription = new CPrescriptionLabo();
$prescription->load($prescription_id);
$prescription->loadRefsFwd();
$prescription->_ref_praticien->loadRefFunction();
$prescription->_ref_praticien->_ref_function->loadRefsFwd();
$prescription->loadRefsBack();
  $prescription->loadClassification();

$tab_prescription = array();
$tab_pack_prescription = array();

// Creation d'un nouveau fichier pdf
$pdf = new CPrescriptionPdf("P", "mm", "A4", true); 

// Chargement de l'etablissement
$etab = new CGroups();
$etab->load($g);

// Affichage de l'entete du document
// Impossible d'utiliser mbNormal.gif ==> format gif non support�
$image = "../../style/$uistyle/images/pictures/logo.jpg";

// Si le style ne possede pas de logo, on applique le logo par defaut de mediboard
if(!is_file("./style/$uistyle/images/pictures/logo.jpg")){
  $image = "logo.jpg";
}

$taille = "75";
$texte = "$etab->_view\n$etab->adresse\n$etab->cp $etab->ville\nTel: $etab->tel";
$pdf->SetHeaderData($image, $taille, "", $texte);

// D�finition des marges de la pages
$pdf->SetMargins(15, 40);

// D�finition de la police et de la taille de l'entete
$pdf->setHeaderFont(Array("vera", '', "10"));

// Creation d'une nouvelle page
$pdf->AddPage();

$praticien =& $prescription->_ref_praticien;
$patient =& $prescription->_ref_patient;

// Affichage du praticien et du patient � l'aide d'un tableau
$pdf->createTab($pdf->viewPraticien($praticien->_view,$praticien->_ref_function->_view, $praticien->_ref_function->_ref_group->_view),
                $pdf->viewPatient($patient->_view, mbTranformTime($patient->naissance,null,'%d-%m-%y'), $patient->adresse, $patient->cp, $patient->ville, $patient->tel));

$urgent = "";
if($prescription->urgence){
	$urgent = "(URGENT)";
}
$pdf->setY(65);
$pdf->writeHTML(utf8_encode("<b>Pr�l�vement du ".(mbTranformTime($prescription->date,null,'%d-%m-%y � %H:%M'))." ".$urgent."</b>"));

$pdf->setY(90);


$pdf->SetFillColor(246,246,246);
$pdf->Cell(25,7,utf8_encode("Code"),1,0,'C',1);
$pdf->Cell(85,7,utf8_encode("Libell�"),1,0,'C',1);
$pdf->Cell(30,7,utf8_encode("R�sultat"),1,0,'C',1);
$pdf->Cell(20,7,utf8_encode("Unit�"),1,0,'C',1);
$pdf->Cell(20,7,utf8_encode("Normes"),1,0,'C',1);
$pdf->Ln();


  
foreach($prescription->_ref_classification_roots as $_catalogue){
  foreach($_catalogue->_ref_prescription_items as $_item){
  	$analyse = $_item->_ref_examen_labo;
  
	  $pdf->Cell(25,7,utf8_encode($analyse->libelle),1,0,'L',0);
	  $pdf->Cell(85,7,utf8_encode(),1,0,'L',0);
		$pdf->Cell(30,7,utf8_encode(),1,0,'L',0);
	  $pdf->Cell(20,7,utf8_encode(),1,0,'L',0);
	  $pdf->Cell(20,7,utf8_encode(),1,0,'L',0);
		$pdf->Ln();

  }
}


// Nom du fichier: prescription-xxxxxxxx.pdf   / I : sortie standard
$pdf->Output("resultat-$prescription->_id.pdf","I");

?>