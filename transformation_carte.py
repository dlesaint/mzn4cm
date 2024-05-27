import xml.etree.ElementTree as ET

def parse_concepts(concept_element):
    concepts = []
    influences = []
    
    def traverse_concepts(concept, parent_id=None):
        concept_id = concept.get('id')
        concept_label = concept.get('label')
        concepts.append((concept_id, concept_label))
        
        for child in concept:
            if child.tag == 'concept':
                traverse_concepts(child, concept_id)
                
    traverse_concepts(concept_element)
    return concepts, influences

def parse_influences(carte_element):
    influences = []
    for influence in carte_element.findall('influence'):
        from_concept = influence.get('from')
        to_concept = influence.get('to')
        valeur = influence.get('valeur')
        influences.append((from_concept, to_concept, valeur))
    return influences

def transform_xml_to_cmap(xml_string):
    root = ET.fromstring(xml_string)
    
    cartes = []
    concepts_dict = {}
    influences_dict = {}
    
    ontologie = root.find('ontologie')
    for concept in ontologie.findall('concept'):
        concepts, influences = parse_concepts(concept)
        for concept_id, concept_label in concepts:
            concepts_dict[concept_id] = concept_label

    cartes_element = root.find('cartes')
    for carte in cartes_element.findall('carte'):
        carte_data = {
            'name': carte.find('designer').get('nom'),
            'node_labels': [],
            'arc_labels': []
        }
        
        for concept in carte.findall('concept'):
            concept_id = concept.get('id')
            carte_data['node_labels'].append(concept_id)
        
        influences = parse_influences(carte)
        for from_concept, to_concept, valeur in influences:
            carte_data['arc_labels'].append((from_concept, to_concept, valeur))
        
        cartes.append(carte_data)
    
    return cartes, concepts_dict

def format_cmap(carte, concepts_dict):
    node_labels = [
        f'(node:{i+1}, concept:(name:"{concepts_dict[concept]}"))'
        for i, concept in enumerate(carte['node_labels'])
    ]
    sorted_arc_labels = sorted(
        carte['arc_labels']
    )
    arc_labels = [
        f'(arc:(t:{carte["node_labels"].index(from_concept)+1}, h:{carte["node_labels"].index(to_concept)+1}), influence:(iblock:[{valeur},4]))'
        for from_concept, to_concept, valeur in carte['arc_labels']
    ]
    
    cmap_string = f"""
    icmap =(
    % icm_{carte['name']} = (
        % name
        name:"{carte['name']}",

        % i-type
        itype: itype,
        
        % node-labeling concepts
        node_labels:[
            {", ".join(node_labels)}
        ],
        
        % arc-labeling influence blocks
        arc_labels:[
            {", ".join(arc_labels)}
        ],
    );
    """
    
    return cmap_string

def save_cmap_to_file(carte, concepts_dict, directory):
    cmap_string = format_cmap(carte, concepts_dict)
    file_name = f"{directory}/{carte['name']}.dzn"
    with open(file_name,'w', encoding='utf-8') as file:
        file.write(cmap_string)
    print(f"Saved: {file_name}")

def convert_xml_to_cmap(xml_string, directory):
    cartes, concepts_dict = transform_xml_to_cmap(xml_string)
    for carte in cartes:
        save_cmap_to_file(carte, concepts_dict,directory)

# Exemple d'utilisation
xml_input = """
<cogxml2>
<valeurs type="enumerate" valueType="string">
<valeur>-4</valeur>
<valeur>-3</valeur>
<valeur>-2</valeur>
<valeur>-1</valeur>
<valeur>1</valeur>
<valeur>2</valeur>
<valeur>3</valeur>
<valeur>4</valeur>
</valeurs>
<ontologie>
<concept id="c0" label="Externalite" type="neutral" x="0.0" y="0.0">
<concept id="c587" label="AugmentationNombreNavires" type="neutral" x="0.0" y="0.0">
<concept id="c640" label="AugmentationNombreNaviresPélagiques" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c588" label="AutresUsages" type="neutral" x="0.0" y="0.0">
<concept id="c637" label="Eolienne" type="neutral" x="0.0" y="0.0"/>
<concept id="c638" label="ExtractionDeGranulats" type="neutral" x="0.0" y="0.0"/>
<concept id="c639" label="PechePlaisancière" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c589" label="Avaries" type="neutral" x="0.0" y="0.0">
<concept id="c627" label="AugmentationAvaries" type="neutral" x="0.0" y="0.0">
<concept id="c633" label="AugmentationAvariesFilet" type="neutral" x="0.0" y="0.0"/>
<concept id="c634" label="AugmentationPannes" type="neutral" x="0.0" y="0.0">
<concept id="c636" label="AugmentationPannesMoteur" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c635" label="AugmentationPerteMateriel" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c628" label="DiminutionAvaries" type="neutral" x="0.0" y="0.0">
<concept id="c629" label="DiminutionAvariesFilet" type="neutral" x="0.0" y="0.0"/>
<concept id="c630" label="DiminutionPannes" type="neutral" x="0.0" y="0.0">
<concept id="c632" label="DiminutionPannesMoteur" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c631" label="DiminutionPerteMateriel" type="neutral" x="0.0" y="0.0"/>
</concept>
</concept>
<concept id="c590" label="CoefficientMaree" type="neutral" x="0.0" y="0.0">
<concept id="c625" label="PetitCoefficient" type="neutral" x="0.0" y="0.0"/>
<concept id="c626" label="GrandCoefficient" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c591" label="ConflitAvecAutrePecherie" type="neutral" x="0.0" y="0.0">
<concept id="c617" label="ConflitAvecArtsTrainants" type="neutral" x="0.0" y="0.0">
<concept id="c623" label="ConcurrencePélagique" type="neutral" x="0.0" y="0.0">
<concept id="c624" label="ConcurrencePélagiqueAuPrintemps" type="neutral" x="0.0" y="0.0"/>
</concept>
</concept>
<concept id="c618" label="ConflitAvecAutreChalutier" type="neutral" x="0.0" y="0.0">
<concept id="c621" label="ConflitAvecAutreChalutierPelagique" type="neutral" x="0.0" y="0.0"/>
<concept id="c622" label="ConflitAvecChalutierEspagnol" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c619" label="ConflitAvecAutreMetier" type="neutral" x="0.0" y="0.0"/>
<concept id="c620" label="ConflitAvecSenneDanoise" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c592" label="Meteo" type="neutral" x="0.0" y="0.0">
<concept id="c614" label="BelleMeteo" type="neutral" x="0.0" y="0.0"/>
<concept id="c615" label="MauvaiseMeteo" type="neutral" x="0.0" y="0.0">
<concept id="c616" label="MauvaiseMétéoOctobreNovembre" type="neutral" x="0.0" y="0.0"/>
</concept>
</concept>
<concept id="c593" label="OrganisationProducteur" type="neutral" x="0.0" y="0.0">
<concept id="c611" label="OrganisationDeLOP" type="neutral" x="0.0" y="0.0">
<concept id="c613" label="MauvaiseOrganisationDeLOP" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c612" label="AdhésionOP" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c594" label="Ressource" type="neutral" x="0.0" y="0.0">
<concept id="c603" label="DestructionRessource" type="neutral" x="0.0" y="0.0">
<concept id="c608" label="DestructionParLesGrosMétiers" type="neutral" x="0.0" y="0.0"/>
<concept id="c609" label="Surpêche" type="neutral" x="0.0" y="0.0">
<concept id="c610" label="SurpêcheHiver" type="neutral" x="0.0" y="0.0"/>
</concept>
</concept>
<concept id="c604" label="RessourceAbondante" type="neutral" x="0.0" y="0.0"/>
<concept id="c605" label="RessourceAvecIncertitudeDeCapture" type="neutral" x="0.0" y="0.0"/>
<concept id="c606" label="RessourceMobile" type="neutral" x="0.0" y="0.0"/>
<concept id="c607" label="RessourcePréservée" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c595" label="Saisonnalite" type="neutral" x="0.0" y="0.0">
<concept id="c601" label="SaisonnaliteImportante" type="neutral" x="0.0" y="0.0"/>
<concept id="c602" label="SaisonnalitePeuImportante" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c596" label="Tourisme" type="neutral" x="0.0" y="0.0"/>
<concept id="c597" label="pollution" type="neutral" x="0.0" y="0.0">
<concept id="c599" label="PollutionEau" type="neutral" x="0.0" y="0.0"/>
<concept id="c600" label="pollution_atmospherique" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c598" label="RéchauffementClimatique" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c1" label="FacteurHumain" type="neutral" x="0.0" y="0.0">
<concept id="c486" label="ComposanteHumaine" type="neutral" x="0.0" y="0.0">
<concept id="c561" label="Equipage" type="neutral" x="0.0" y="0.0">
<concept id="c579" label="EquipageCompetent" type="neutral" x="0.0" y="0.0">
<concept id="c586" label="EquipageCompétentEnManutention" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c580" label="EquipageIncompetent" type="neutral" x="0.0" y="0.0"/>
<concept id="c581" label="EquipageInstable" type="neutral" x="0.0" y="0.0"/>
<concept id="c582" label="EquipageNombreux" type="neutral" x="0.0" y="0.0"/>
<concept id="c583" label="EquipagePeuNombreux" type="neutral" x="0.0" y="0.0">
<concept id="c585" label="PasDEquipage" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c584" label="EquipageStable" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c562" label="Patron" type="neutral" x="0.0" y="0.0">
<concept id="c563" label="PatronAvecLongueExpérienceDeMatelot" type="neutral" x="0.0" y="0.0"/>
<concept id="c564" label="PatronAyantPratique" type="neutral" x="0.0" y="0.0"/>
<concept id="c565" label="PatronConnaissantCommandement" type="neutral" x="0.0" y="0.0"/>
<concept id="c566" label="PatronConnaissantEngin" type="neutral" x="0.0" y="0.0"/>
<concept id="c567" label="PatronConnaissantMetier" type="neutral" x="0.0" y="0.0">
<concept id="c575" label="PatronConnaissantMetierAutrePort" type="neutral" x="0.0" y="0.0"/>
<concept id="c576" label="PatronConnaissantMetierDansPort" type="neutral" x="0.0" y="0.0"/>
<concept id="c577" label="PatronConnaissantMetierParHeritage" type="neutral" x="0.0" y="0.0"/>
<concept id="c578" label="PatronConnaissantPlusieursMetiers" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c568" label="PatronConnaissantPasMetier" type="neutral" x="0.0" y="0.0">
<concept id="c573" label="PatronConnaissantPasEngin" type="neutral" x="0.0" y="0.0"/>
<concept id="c574" label="PatronConnaissantPasZone" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c569" label="PatronConnaissantZone" type="neutral" x="0.0" y="0.0"/>
<concept id="c570" label="PatronVoulantExperimenterMetier" type="neutral" x="0.0" y="0.0"/>
<concept id="c571" label="PatronVoulantExplorerZone" type="neutral" x="0.0" y="0.0"/>
<concept id="c572" label="PatronConnaissantNavire" type="neutral" x="0.0" y="0.0"/>
</concept>
</concept>
<concept id="c487" label="ConditionDeTravail" type="neutral" x="0.0" y="0.0">
<concept id="c532" label="AméliorationConditionsDeTravail" type="neutral" x="0.0" y="0.0"/>
<concept id="c533" label="AugmentationTravail" type="neutral" x="0.0" y="0.0">
<concept id="c560" label="AugmentationManutention" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c534" label="Confort" type="neutral" x="0.0" y="0.0">
<concept id="c558" label="ConfortEquipage" type="neutral" x="0.0" y="0.0"/>
<concept id="c559" label="ConfortPatron" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c535" label="LiberteDeChoix" type="neutral" x="0.0" y="0.0">
<concept id="c554" label="AugmentationLiberteDeChoix" type="neutral" x="0.0" y="0.0">
<concept id="c557" label="AugmentationLiberteDeChoixDuMomentDeSortie" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c555" label="DiminutionLiberteDeChoix" type="neutral" x="0.0" y="0.0">
<concept id="c556" label="DiminutionLiberteDeChoixDuMomentDeSortie" type="neutral" x="0.0" y="0.0"/>
</concept>
</concept>
<concept id="c536" label="ObligationResultat" type="neutral" x="0.0" y="0.0"/>
<concept id="c537" label="ObligationTravail" type="neutral" x="0.0" y="0.0"/>
<concept id="c538" label="Penibilite" type="neutral" x="0.0" y="0.0">
<concept id="c552" label="Fatigue" type="neutral" x="0.0" y="0.0"/>
<concept id="c553" label="ProblèmeSanté" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c539" label="Remuneration" type="neutral" x="0.0" y="0.0">
<concept id="c549" label="RemunerationSure" type="neutral" x="0.0" y="0.0"/>
<concept id="c550" label="SalaireEtPartArmementReguliers" type="neutral" x="0.0" y="0.0"/>
<concept id="c551" label="ComplémentRémunération" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c540" label="Rengaine" type="neutral" x="0.0" y="0.0">
<concept id="c547" label="EviterRengaine" type="neutral" x="0.0" y="0.0"/>
<concept id="c548" label="RengaineImportante" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c541" label="RythmeDeTravail" type="neutral" x="0.0" y="0.0">
<concept id="c545" label="RythmeDeTravailEleve" type="neutral" x="0.0" y="0.0"/>
<concept id="c546" label="RythmeDeTravailRegulier" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c542" label="SecuriteTravail" type="neutral" x="0.0" y="0.0"/>
<concept id="c543" label="Stress" type="neutral" x="0.0" y="0.0"/>
<concept id="c544" label="TempsDeTravailEquipagePrevuALAvance" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c488" label="FacteurPsychoSocial" type="neutral" x="0.0" y="0.0">
<concept id="c489" label="ActiviteExtraprofessionnelle" type="neutral" x="0.0" y="0.0"/>
<concept id="c490" label="Ambition" type="neutral" x="0.0" y="0.0">
<concept id="c524" label="Volonte" type="neutral" x="0.0" y="0.0">
<concept id="c525" label="VolonteDInnover" type="neutral" x="0.0" y="0.0"/>
<concept id="c526" label="VolonteDeCommander" type="neutral" x="0.0" y="0.0"/>
<concept id="c527" label="VolonteDeModernisation" type="neutral" x="0.0" y="0.0"/>
<concept id="c528" label="VolonteDeVoirLaFamille" type="neutral" x="0.0" y="0.0"/>
<concept id="c529" label="VolontéPélagique" type="neutral" x="0.0" y="0.0"/>
<concept id="c530" label="VolonteDeVarierLesMétiers" type="neutral" x="0.0" y="0.0"/>
<concept id="c531" label="VolontéDeGarderDesPrixCorrects" type="neutral" x="0.0" y="0.0"/>
</concept>
</concept>
<concept id="c491" label="EnvironnementSocialPeche" type="neutral" x="0.0" y="0.0">
<concept id="c519" label="AmisPeche" type="neutral" x="0.0" y="0.0"/>
<concept id="c520" label="FamillePeche" type="neutral" x="0.0" y="0.0">
<concept id="c523" label="Epouse" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c521" label="NecessiteEntenteInterPatronsInterEquipages" type="neutral" x="0.0" y="0.0"/>
<concept id="c522" label="EntentePatronEquipage" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c492" label="Gout" type="neutral" x="0.0" y="0.0">
<concept id="c516" label="GoutPelagique" type="neutral" x="0.0" y="0.0"/>
<concept id="c517" label="PasDeGout" type="neutral" x="0.0" y="0.0"/>
<concept id="c518" label="Passion" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c493" label="Incertitude" type="neutral" x="0.0" y="0.0"/>
<concept id="c494" label="Moral" type="neutral" x="0.0" y="0.0">
<concept id="c514" label="MoralEquipage" type="neutral" x="0.0" y="0.0"/>
<concept id="c515" label="MoralPatron" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c495" label="Motivation" type="neutral" x="0.0" y="0.0">
<concept id="c508" label="BesoinDEtreActif" type="neutral" x="0.0" y="0.0"/>
<concept id="c509" label="Competition" type="neutral" x="0.0" y="0.0">
<concept id="c512" label="CompetitionEntreNavires" type="neutral" x="0.0" y="0.0"/>
<concept id="c513" label="CompetitionPortuaire" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c510" label="MotivationEquipage" type="neutral" x="0.0" y="0.0"/>
<concept id="c511" label="MotivationPatron" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c496" label="Plaisir" type="neutral" x="0.0" y="0.0">
<concept id="c505" label="PlaisirDePecher" type="neutral" x="0.0" y="0.0"/>
<concept id="c506" label="PlaisirEquipage" type="neutral" x="0.0" y="0.0"/>
<concept id="c507" label="PlaisirPatron" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c497" label="QualiteDeVie" type="neutral" x="0.0" y="0.0">
<concept id="c502" label="VieDeFamille" type="neutral" x="0.0" y="0.0">
<concept id="c503" label="AmeliorationVieDeFamille" type="neutral" x="0.0" y="0.0"/>
<concept id="c504" label="DeteriorationVieDeFamille" type="neutral" x="0.0" y="0.0"/>
</concept>
</concept>
<concept id="c498" label="SatisfactionDeRéussite" type="neutral" x="0.0" y="0.0">
<concept id="c501" label="RéussiteDansMétierDifficile" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c499" label="Surprise" type="neutral" x="0.0" y="0.0"/>
<concept id="c500" label="ChangementCompletDeMétier" type="neutral" x="0.0" y="0.0"/>
</concept>
</concept>
<concept id="c2" label="DescriptionMétier" type="neutral" x="0.0" y="0.0">
<concept id="c306" label="ArretMetier" type="neutral" x="0.0" y="0.0">
<concept id="c483" label="ArretCrevette" type="neutral" x="0.0" y="0.0"/>
<concept id="c484" label="ArrêtFilet" type="neutral" x="0.0" y="0.0"/>
<concept id="c485" label="ArretCivelle" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c307" label="Engin" type="neutral" x="0.0" y="0.0">
<concept id="c432" label="Chalut" type="neutral" x="0.0" y="0.0">
<concept id="c472" label="ChalutDeFond" type="neutral" x="0.0" y="0.0">
<concept id="c480" label="Chalut-boeuf_de_fond" type="neutral" x="0.0" y="0.0"/>
<concept id="c481" label="ChalutLangoustine" type="neutral" x="0.0" y="0.0"/>
<concept id="c482" label="Chalut_jumeau_a_panneaux" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c473" label="ChalutPélagique" type="neutral" x="0.0" y="0.0">
<concept id="c477" label="ChalutPelagique4Panneaux" type="neutral" x="0.0" y="0.0"/>
<concept id="c478" label="ChalutPelagiqueEnBoeuf" type="neutral" x="0.0" y="0.0"/>
<concept id="c479" label="Chalut_pelagique_a_panneaux" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c474" label="Chalut_a_grande_ouverture_verticale" type="neutral" x="0.0" y="0.0"/>
<concept id="c475" label="Tamis_a_civelles" type="neutral" x="0.0" y="0.0"/>
<concept id="c476" label="chalut_a_perche" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c433" label="Drague" type="neutral" x="0.0" y="0.0">
<concept id="c469" label="Drague_mecanisee" type="neutral" x="0.0" y="0.0"/>
<concept id="c470" label="Drague_remorquee_par_bateau" type="neutral" x="0.0" y="0.0"/>
<concept id="c471" label="Drague_a_main_utilisee_a_bord_d'un_bateau" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c434" label="EnginContraignant" type="neutral" x="0.0" y="0.0">
<concept id="c466" label="EnginPeuContrignant" type="neutral" x="0.0" y="0.0"/>
<concept id="c467" label="EnginMoinsContraignant" type="neutral" x="0.0" y="0.0">
<concept id="c468" label="EnginMoinsContraignantQueFilet" type="neutral" x="0.0" y="0.0"/>
</concept>
</concept>
<concept id="c435" label="EnginPasContraignant" type="neutral" x="0.0" y="0.0"/>
<concept id="c436" label="EnginSélectif" type="neutral" x="0.0" y="0.0"/>
<concept id="c437" label="Filet" type="neutral" x="0.0" y="0.0">
<concept id="c453" label="Filet_souleve" type="neutral" x="0.0" y="0.0">
<concept id="c463" label="Filet_souleve_fixe_manoeuvre_du_rivage" type="neutral" x="0.0" y="0.0"/>
<concept id="c464" label="Filet_souleve_manoeuvre_par_bateau" type="neutral" x="0.0" y="0.0">
<concept id="c465" label="ChalutLateral" type="neutral" x="0.0" y="0.0"/>
</concept>
</concept>
<concept id="c454" label="Filet_tournant" type="neutral" x="0.0" y="0.0">
<concept id="c461" label="Sans_coulisses" type="neutral" x="0.0" y="0.0"/>
<concept id="c462" label="Senne_coulissante" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c455" label="filet_maillant" type="neutral" x="0.0" y="0.0">
<concept id="c457" label="Filet_maillant_cale" type="neutral" x="0.0" y="0.0"/>
<concept id="c458" label="Filet_maillant_derivant" type="neutral" x="0.0" y="0.0"/>
<concept id="c459" label="Filet_maillant_encerclant" type="neutral" x="0.0" y="0.0"/>
<concept id="c460" label="Tremail" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c456" label="FiletDeFond" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c438" label="Ligne_et_hamecon" type="neutral" x="0.0" y="0.0">
<concept id="c447" label="Ligne_a_main" type="neutral" x="0.0" y="0.0"/>
<concept id="c448" label="Ligne_de_traine" type="neutral" x="0.0" y="0.0"/>
<concept id="c449" label="Palangre" type="neutral" x="0.0" y="0.0">
<concept id="c451" label="Palangre_calee" type="neutral" x="0.0" y="0.0"/>
<concept id="c452" label="Palangre_derivante" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c450" label="PecheALaCanne" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c439" label="PetitsMetiers" type="neutral" x="0.0" y="0.0"/>
<concept id="c440" label="Piege" type="neutral" x="0.0" y="0.0">
<concept id="c446" label="Casier" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c441" label="Senne" type="neutral" x="0.0" y="0.0">
<concept id="c442" label="Senne_danoise" type="neutral" x="0.0" y="0.0"/>
<concept id="c443" label="Senne_ecossaise" type="neutral" x="0.0" y="0.0"/>
<concept id="c444" label="Senne_manoeuvree_par_deux_bateaux" type="neutral" x="0.0" y="0.0"/>
<concept id="c445" label="senne_de_plage" type="neutral" x="0.0" y="0.0"/>
</concept>
</concept>
<concept id="c308" label="Espece" type="neutral" x="0.0" y="0.0">
<concept id="c386" label="EspeceAForteValeur" type="neutral" x="0.0" y="0.0"/>
<concept id="c387" label="EspeceAbsente" type="neutral" x="0.0" y="0.0"/>
<concept id="c388" label="EspeceCiblee" type="neutral" x="0.0" y="0.0"/>
<concept id="c389" label="EspeceNonCiblee" type="neutral" x="0.0" y="0.0"/>
<concept id="c390" label="EspecePresente" type="neutral" x="0.0" y="0.0">
<concept id="c430" label="EspeceNoblePresente" type="neutral" x="0.0" y="0.0"/>
<concept id="c431" label="SardinePresente" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c391" label="EspeceProcheDuPort" type="neutral" x="0.0" y="0.0"/>
<concept id="c392" label="Poisson" type="neutral" x="0.0" y="0.0">
<concept id="c411" label="Bar" type="neutral" x="0.0" y="0.0">
<concept id="c427" label="BarALaCanne" type="neutral" x="0.0" y="0.0"/>
<concept id="c428" label="BarAuFilet" type="neutral" x="0.0" y="0.0"/>
<concept id="c429" label="BarDeLigne" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c412" label="Civelle" type="neutral" x="0.0" y="0.0"/>
<concept id="c413" label="Congre" type="neutral" x="0.0" y="0.0"/>
<concept id="c414" label="Dorade" type="neutral" x="0.0" y="0.0">
<concept id="c426" label="DoradeRoyale" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c415" label="LieuJaune" type="neutral" x="0.0" y="0.0"/>
<concept id="c416" label="Merlan" type="neutral" x="0.0" y="0.0"/>
<concept id="c417" label="Merlu" type="neutral" x="0.0" y="0.0">
<concept id="c425" label="MerluAuFilet" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c418" label="Sardine" type="neutral" x="0.0" y="0.0"/>
<concept id="c419" label="Thon" type="neutral" x="0.0" y="0.0">
<concept id="c424" label="ThonLigneTrainante" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c420" label="cabillaud" type="neutral" x="0.0" y="0.0"/>
<concept id="c421" label="Lotte" type="neutral" x="0.0" y="0.0"/>
<concept id="c422" label="Sole" type="neutral" x="0.0" y="0.0">
<concept id="c423" label="SoleAuFilet" type="neutral" x="0.0" y="0.0"/>
</concept>
</concept>
<concept id="c393" label="crustace" type="neutral" x="0.0" y="0.0">
<concept id="c401" label="Homard" type="neutral" x="0.0" y="0.0">
<concept id="c410" label="HomardCasier" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c402" label="Langoustine" type="neutral" x="0.0" y="0.0">
<concept id="c409" label="LangoustineAuChalut" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c403" label="crevette" type="neutral" x="0.0" y="0.0">
<concept id="c405" label="crevette_grise" type="neutral" x="0.0" y="0.0">
<concept id="c408" label="CrevetteGriseAuChalut" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c406" label="crevette_rose" type="neutral" x="0.0" y="0.0">
<concept id="c407" label="CrevetteRoseCasier" type="neutral" x="0.0" y="0.0"/>
</concept>
</concept>
<concept id="c404" label="Crabe" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c394" label="mollusque" type="neutral" x="0.0" y="0.0">
<concept id="c396" label="CoquilleStJacques" type="neutral" x="0.0" y="0.0">
<concept id="c400" label="CoquilleALaDrague" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c397" label="Seiche" type="neutral" x="0.0" y="0.0"/>
<concept id="c398" label="clam" type="neutral" x="0.0" y="0.0"/>
<concept id="c399" label="peigne" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c395" label="EspeceRecherchée" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c309" label="Materiel" type="neutral" x="0.0" y="0.0"/>
<concept id="c310" label="Navire" type="neutral" x="0.0" y="0.0">
<concept id="c366" label="Chalutier" type="neutral" x="0.0" y="0.0"/>
<concept id="c367" label="ConstructionNavire" type="neutral" x="0.0" y="0.0">
<concept id="c383" label="ConstructionNavireMoinsDe10m" type="neutral" x="0.0" y="0.0"/>
<concept id="c384" label="ConstructionNavire12m" type="neutral" x="0.0" y="0.0"/>
<concept id="c385" label="ConstructionNavirePlusDe16m" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c368" label="NavireAménagé" type="neutral" x="0.0" y="0.0"/>
<concept id="c369" label="NavireAncien" type="neutral" x="0.0" y="0.0"/>
<concept id="c370" label="NavireModerne" type="neutral" x="0.0" y="0.0"/>
<concept id="c371" label="NavirePerformant" type="neutral" x="0.0" y="0.0"/>
<concept id="c372" label="NavirePolyvalent" type="neutral" x="0.0" y="0.0"/>
<concept id="c373" label="TailleNavire" type="neutral" x="0.0" y="0.0">
<concept id="c378" label="GrosNavire" type="neutral" x="0.0" y="0.0">
<concept id="c382" label="NavireGrosseCale" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c379" label="PetitNavire" type="neutral" x="0.0" y="0.0">
<concept id="c380" label="PetitNavireACivelles" type="neutral" x="0.0" y="0.0"/>
<concept id="c381" label="NavireMoinsDe12m" type="neutral" x="0.0" y="0.0"/>
</concept>
</concept>
<concept id="c374" label="VieuxNavire" type="neutral" x="0.0" y="0.0"/>
<concept id="c375" label="palangrier" type="neutral" x="0.0" y="0.0"/>
<concept id="c376" label="Kerflous" type="neutral" x="0.0" y="0.0"/>
<concept id="c377" label="navire_bigouden" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c311" label="Zone" type="neutral" x="0.0" y="0.0">
<concept id="c312" label="ZoneArtsTrainants" type="neutral" x="0.0" y="0.0">
<concept id="c365" label="ZoneChalutLangoustine" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c313" label="ZoneBenthique" type="neutral" x="0.0" y="0.0"/>
<concept id="c314" label="ZoneBonne" type="neutral" x="0.0" y="0.0"/>
<concept id="c315" label="ZoneCotiere" type="neutral" x="0.0" y="0.0"/>
<concept id="c316" label="ZoneDemersale" type="neutral" x="0.0" y="0.0"/>
<concept id="c317" label="ZoneEauChaude" type="neutral" x="0.0" y="0.0"/>
<concept id="c318" label="ZoneEauFroide" type="neutral" x="0.0" y="0.0"/>
<concept id="c319" label="ZoneEauTemperee" type="neutral" x="0.0" y="0.0"/>
<concept id="c320" label="ZonePelagique" type="neutral" x="0.0" y="0.0"/>
<concept id="c321" label="ZonePeuFrequentee" type="neutral" x="0.0" y="0.0">
<concept id="c364" label="ZoneARisque" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c322" label="ZoneProcheMareyeur" type="neutral" x="0.0" y="0.0"/>
<concept id="c323" label="ZoneSansArtsTrainants" type="neutral" x="0.0" y="0.0"/>
<concept id="c324" label="ZoneSansConcurrence" type="neutral" x="0.0" y="0.0"/>
<concept id="c325" label="ZoneSansRisque" type="neutral" x="0.0" y="0.0"/>
<concept id="c326" label="ZoneSelonCourantologie" type="neutral" x="0.0" y="0.0">
<concept id="c362" label="ZoneACourant" type="neutral" x="0.0" y="0.0"/>
<concept id="c363" label="ZoneSansCourant" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c327" label="ZoneSelonDistance" type="neutral" x="0.0" y="0.0">
<concept id="c359" label="ZoneEloignee" type="neutral" x="0.0" y="0.0"/>
<concept id="c360" label="ZoneProche" type="neutral" x="0.0" y="0.0">
<concept id="c361" label="ZoneDes1,5M" type="neutral" x="0.0" y="0.0"/>
</concept>
</concept>
<concept id="c328" label="ZoneSelonFond" type="neutral" x="0.0" y="0.0">
<concept id="c352" label="ZoneRocheuse" type="neutral" x="0.0" y="0.0"/>
<concept id="c353" label="ZoneSableuse" type="neutral" x="0.0" y="0.0"/>
<concept id="c354" label="ZoneVaseuse" type="neutral" x="0.0" y="0.0"/>
<concept id="c355" label="fond" type="neutral" x="0.0" y="0.0">
<concept id="c356" label="fond_doux" type="neutral" x="0.0" y="0.0"/>
<concept id="c357" label="fond_dur" type="neutral" x="0.0" y="0.0"/>
<concept id="c358" label="fond_irregulier" type="neutral" x="0.0" y="0.0"/>
</concept>
</concept>
<concept id="c329" label="ZoneSelonGeographie" type="neutral" x="0.0" y="0.0">
<concept id="c345" label="ZoneAccore" type="neutral" x="0.0" y="0.0"/>
<concept id="c346" label="ZonePlateau" type="neutral" x="0.0" y="0.0"/>
<concept id="c347" label="ZoneTalus" type="neutral" x="0.0" y="0.0"/>
<concept id="c348" label="plateau" type="neutral" x="0.0" y="0.0">
<concept id="c351" label="plateau_continental" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c349" label="talus" type="neutral" x="0.0" y="0.0">
<concept id="c350" label="talus_continental" type="neutral" x="0.0" y="0.0"/>
</concept>
</concept>
<concept id="c330" label="ZoneSelonNatureMilieu" type="neutral" x="0.0" y="0.0">
<concept id="c343" label="ZoneEstuarienne" type="neutral" x="0.0" y="0.0"/>
<concept id="c344" label="ZoneMarine" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c331" label="ZoneSelonNom" type="neutral" x="0.0" y="0.0">
<concept id="c341" label="Ouessant" type="neutral" x="0.0" y="0.0"/>
<concept id="c342" label="mer_celtique" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c332" label="ZoneSelonProfondeur" type="neutral" x="0.0" y="0.0">
<concept id="c338" label="ZonePeuProfonde" type="neutral" x="0.0" y="0.0"/>
<concept id="c339" label="ZoneProfonde" type="neutral" x="0.0" y="0.0"/>
<concept id="c340" label="eau_profonde" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c333" label="recif" type="neutral" x="0.0" y="0.0">
<concept id="c337" label="recif_coralien" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c334" label="ridin" type="neutral" x="0.0" y="0.0">
<concept id="c336" label="ridin_serre" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c335" label="ZoneRestreinte" type="neutral" x="0.0" y="0.0"/>
</concept>
</concept>
<concept id="c3" label="Tactiques" type="neutral" x="0.0" y="0.0">
<concept id="c272" label="ActiviteProspection" type="neutral" x="0.0" y="0.0"/>
<concept id="c273" label="Adaptabilite" type="neutral" x="0.0" y="0.0">
<concept id="c300" label="AdaptabiliteMeteo" type="neutral" x="0.0" y="0.0"/>
<concept id="c301" label="AdaptabilitePrix" type="neutral" x="0.0" y="0.0"/>
<concept id="c302" label="AdaptabiliteSaison" type="neutral" x="0.0" y="0.0"/>
<concept id="c303" label="AdaptabiliteEspece" type="neutral" x="0.0" y="0.0"/>
<concept id="c304" label="AdaptabiliteDeplacementEspece" type="neutral" x="0.0" y="0.0">
<concept id="c305" label="AdaptabiliteDeplacementThon" type="neutral" x="0.0" y="0.0"/>
</concept>
</concept>
<concept id="c274" label="ArriveeEnPremierSurZone" type="neutral" x="0.0" y="0.0"/>
<concept id="c275" label="ChangerDeZoneDePeche" type="neutral" x="0.0" y="0.0"/>
<concept id="c276" label="CommunicationEntrePatrons" type="neutral" x="0.0" y="0.0">
<concept id="c297" label="CommunicationEntrePatronsAmis" type="neutral" x="0.0" y="0.0"/>
<concept id="c298" label="CommunicationEntrePatronsCaseyeurs" type="neutral" x="0.0" y="0.0"/>
<concept id="c299" label="CommunicationEntrePatronsFileyeurs" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c277" label="EquipeMaintenanceATerre" type="neutral" x="0.0" y="0.0"/>
<concept id="c278" label="LongDeplacementEnVoitureDomicileNavire" type="neutral" x="0.0" y="0.0"/>
<concept id="c279" label="ModificationChalutSelonSaison" type="neutral" x="0.0" y="0.0"/>
<concept id="c280" label="Observation" type="neutral" x="0.0" y="0.0">
<concept id="c296" label="Observation_sondeur" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c281" label="OptimisationDeplacements" type="neutral" x="0.0" y="0.0"/>
<concept id="c282" label="OptimisationTemps" type="neutral" x="0.0" y="0.0">
<concept id="c291" label="AugmentationPerteTemps" type="neutral" x="0.0" y="0.0"/>
<concept id="c292" label="DiminutionPerteTemps" type="neutral" x="0.0" y="0.0"/>
<concept id="c293" label="OccupationTempsMort" type="neutral" x="0.0" y="0.0"/>
<concept id="c294" label="TempsSommeilCourt" type="neutral" x="0.0" y="0.0"/>
<concept id="c295" label="TempsSommeilLong" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c283" label="PasDeSortie" type="neutral" x="0.0" y="0.0">
<concept id="c290" label="PasDeSortieGrandCoefficient" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c284" label="TraitsDeChalut" type="neutral" x="0.0" y="0.0">
<concept id="c286" label="AugmentationDuNombreDeTraits" type="neutral" x="0.0" y="0.0"/>
<concept id="c287" label="DiminutionTempsDesTraits" type="neutral" x="0.0" y="0.0"/>
<concept id="c288" label="TraitCourt" type="neutral" x="0.0" y="0.0"/>
<concept id="c289" label="TraitLong" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c285" label="TravailMauvaisTemps" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c4" label="FacteurEconomique" type="neutral" x="0.0" y="0.0">
<concept id="c73" label="AugmentationVitesse" type="neutral" x="0.0" y="0.0"/>
<concept id="c74" label="CaracteristiquesEconomiquesDeLEntreprise" type="neutral" x="0.0" y="0.0">
<concept id="c189" label="ActivitePechePromenade" type="neutral" x="0.0" y="0.0"/>
<concept id="c190" label="AmortissementPret" type="neutral" x="0.0" y="0.0">
<concept id="c270" label="AmortissementBateau" type="neutral" x="0.0" y="0.0"/>
<concept id="c271" label="AmortissementPrêtTerminé" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c191" label="Charges" type="neutral" x="0.0" y="0.0">
<concept id="c249" label="AugmentationCharges" type="neutral" x="0.0" y="0.0">
<concept id="c261" label="AugmentationChargesAppat" type="neutral" x="0.0" y="0.0"/>
<concept id="c262" label="AugmentationChargesArmement" type="neutral" x="0.0" y="0.0">
<concept id="c268" label="AugmentationChargesEquipementEtEngin" type="neutral" x="0.0" y="0.0"/>
<concept id="c269" label="AugmentationChargesNavire" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c263" label="AugmentationChargesCommunes" type="neutral" x="0.0" y="0.0">
<concept id="c265" label="AugmentationChargesCarburant" type="neutral" x="0.0" y="0.0"/>
<concept id="c266" label="AugmentationChargesGlace" type="neutral" x="0.0" y="0.0"/>
<concept id="c267" label="AugmentationChargesHuile" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c264" label="AugmentationChargesCooperatives" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c250" label="DiminutionCharges" type="neutral" x="0.0" y="0.0">
<concept id="c252" label="DiminutionChargesAppat" type="neutral" x="0.0" y="0.0"/>
<concept id="c253" label="DiminutionChargesArmement" type="neutral" x="0.0" y="0.0">
<concept id="c259" label="DiminutionChargesEquipementEtEngin" type="neutral" x="0.0" y="0.0"/>
<concept id="c260" label="DiminutionChargesNavire" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c254" label="DiminutionChargesCommunes" type="neutral" x="0.0" y="0.0">
<concept id="c256" label="DiminutionChargesCarburant" type="neutral" x="0.0" y="0.0"/>
<concept id="c257" label="DiminutionChargesGlace" type="neutral" x="0.0" y="0.0"/>
<concept id="c258" label="DiminutionChargesHuile" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c255" label="DiminutionChargesCooperatives" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c251" label="FraisEntretienFaibles" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c192" label="Investissement" type="neutral" x="0.0" y="0.0">
<concept id="c233" label="InvestissementImportant" type="neutral" x="0.0" y="0.0"/>
<concept id="c234" label="InvestissementMateriel" type="neutral" x="0.0" y="0.0">
<concept id="c243" label="InvestissementMaterielElectronique" type="neutral" x="0.0" y="0.0">
<concept id="c247" label="InvestissementGeolocalisation" type="neutral" x="0.0" y="0.0"/>
<concept id="c248" label="InvestissementSonar" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c244" label="InvestissementSurNavire" type="neutral" x="0.0" y="0.0">
<concept id="c245" label="AdaptationNavire" type="neutral" x="0.0" y="0.0"/>
<concept id="c246" label="ModernisationNavire" type="neutral" x="0.0" y="0.0"/>
</concept>
</concept>
<concept id="c235" label="InvestissementNouveauNavire" type="neutral" x="0.0" y="0.0">
<concept id="c238" label="Investissement2eNavire" type="neutral" x="0.0" y="0.0"/>
<concept id="c239" label="InvestissementNouveauGrosChalutier" type="neutral" x="0.0" y="0.0"/>
<concept id="c240" label="InvestissementNouveauNavireModerne" type="neutral" x="0.0" y="0.0">
<concept id="c241" label="InvestissementNouveauChalutierModerneLangoustine" type="neutral" x="0.0" y="0.0"/>
<concept id="c242" label="InvestissementNouveauNavireModernePelagique" type="neutral" x="0.0" y="0.0"/>
</concept>
</concept>
<concept id="c236" label="InvestissementPossible" type="neutral" x="0.0" y="0.0"/>
<concept id="c237" label="InvestissementRepeuplementCrustace" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c193" label="PassagersNombreux" type="neutral" x="0.0" y="0.0"/>
<concept id="c194" label="Production" type="neutral" x="0.0" y="0.0">
<concept id="c212" label="ProductionDiverse" type="neutral" x="0.0" y="0.0"/>
<concept id="c213" label="ProductionEspecesNobles" type="neutral" x="0.0" y="0.0"/>
<concept id="c214" label="ProductionVivante" type="neutral" x="0.0" y="0.0"/>
<concept id="c215" label="QualiteProduction" type="neutral" x="0.0" y="0.0"/>
<concept id="c216" label="ReputationProductionQualite" type="neutral" x="0.0" y="0.0"/>
<concept id="c217" label="ValeurProduction" type="neutral" x="0.0" y="0.0">
<concept id="c231" label="ValeurProductionImportante" type="neutral" x="0.0" y="0.0"/>
<concept id="c232" label="ValeurProductionPeuImportante" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c218" label="VolumeProduction" type="neutral" x="0.0" y="0.0">
<concept id="c219" label="VolumeProductionAppats" type="neutral" x="0.0" y="0.0"/>
<concept id="c220" label="VolumeProductionCrustacés" type="neutral" x="0.0" y="0.0">
<concept id="c229" label="VolumeProductionCrabesHomards" type="neutral" x="0.0" y="0.0"/>
<concept id="c230" label="VolumeProductionCrevettes" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c221" label="VolumeProductionImportant" type="neutral" x="0.0" y="0.0"/>
<concept id="c222" label="VolumeProductionPeuImportant" type="neutral" x="0.0" y="0.0"/>
<concept id="c223" label="VolumeProductionMinimumRentable" type="neutral" x="0.0" y="0.0"/>
<concept id="c224" label="VolumeProductionPoisson" type="neutral" x="0.0" y="0.0">
<concept id="c225" label="VolumeProductionCivelle" type="neutral" x="0.0" y="0.0"/>
<concept id="c226" label="VolumeProductionAnchois" type="neutral" x="0.0" y="0.0"/>
<concept id="c227" label="VolumeProductionBar" type="neutral" x="0.0" y="0.0"/>
<concept id="c228" label="VolumeProductionSole" type="neutral" x="0.0" y="0.0"/>
</concept>
</concept>
</concept>
<concept id="c195" label="Recrutement" type="neutral" x="0.0" y="0.0">
<concept id="c207" label="RecrutementFacile" type="neutral" x="0.0" y="0.0"/>
<concept id="c208" label="RecrutementMatelot" type="neutral" x="0.0" y="0.0">
<concept id="c209" label="RecrutementMatelotDifficile" type="neutral" x="0.0" y="0.0">
<concept id="c211" label="RecrutementMatelotSérieuxDifficile" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c210" label="RecrutementMatelotSupplémentaire" type="neutral" x="0.0" y="0.0"/>
</concept>
</concept>
<concept id="c196" label="Rentabilite" type="neutral" x="0.0" y="0.0">
<concept id="c204" label="Benefices" type="neutral" x="0.0" y="0.0"/>
<concept id="c205" label="ChiffreDAffaires" type="neutral" x="0.0" y="0.0"/>
<concept id="c206" label="RentabilitéFaible" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c197" label="Vente" type="neutral" x="0.0" y="0.0">
<concept id="c198" label="VenteAppats" type="neutral" x="0.0" y="0.0"/>
<concept id="c199" label="VenteNavire" type="neutral" x="0.0" y="0.0">
<concept id="c200" label="PossibilitéVenteNavire" type="neutral" x="0.0" y="0.0"/>
<concept id="c201" label="VenteNavireFaible" type="neutral" x="0.0" y="0.0"/>
<concept id="c202" label="VenteNavireForte" type="neutral" x="0.0" y="0.0"/>
<concept id="c203" label="VenteNavireProchaine" type="neutral" x="0.0" y="0.0"/>
</concept>
</concept>
</concept>
<concept id="c75" label="ChoixTechnique" type="neutral" x="0.0" y="0.0">
<concept id="c148" label="GestionEntreprise" type="neutral" x="0.0" y="0.0">
<concept id="c188" label="GestionDesDeuxNaviresEnBoeuf" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c149" label="GestionMateriel" type="neutral" x="0.0" y="0.0">
<concept id="c167" label="AmeliorationAmenagementEquipement" type="neutral" x="0.0" y="0.0"/>
<concept id="c168" label="AugmentationQuantiteEngin" type="neutral" x="0.0" y="0.0"/>
<concept id="c169" label="BonMateriel" type="neutral" x="0.0" y="0.0"/>
<concept id="c170" label="EntretienMateriel" type="neutral" x="0.0" y="0.0">
<concept id="c184" label="EntretienEnginEtEquipement" type="neutral" x="0.0" y="0.0"/>
<concept id="c185" label="EntretienNavire" type="neutral" x="0.0" y="0.0"/>
<concept id="c186" label="EntretienRegulier" type="neutral" x="0.0" y="0.0"/>
<concept id="c187" label="PeuDEntretien" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c171" label="EssaiMaterielExperimental" type="neutral" x="0.0" y="0.0"/>
<concept id="c172" label="FabricationMateriel" type="neutral" x="0.0" y="0.0"/>
<concept id="c173" label="MatérielABord" type="neutral" x="0.0" y="0.0"/>
<concept id="c174" label="MatérielPourTravaillerSeul" type="neutral" x="0.0" y="0.0"/>
<concept id="c175" label="ModernisationMateriel" type="neutral" x="0.0" y="0.0">
<concept id="c180" label="ModernisationEquipement" type="neutral" x="0.0" y="0.0">
<concept id="c181" label="CarteBathymetrique" type="neutral" x="0.0" y="0.0"/>
<concept id="c182" label="Geolocalisation" type="neutral" x="0.0" y="0.0"/>
<concept id="c183" label="sonar" type="neutral" x="0.0" y="0.0"/>
</concept>
</concept>
<concept id="c176" label="PrevoirPiecesDeRechange" type="neutral" x="0.0" y="0.0"/>
<concept id="c177" label="ChangementRegulierMateriel" type="neutral" x="0.0" y="0.0">
<concept id="c178" label="ChangementRegulierMoteur" type="neutral" x="0.0" y="0.0"/>
<concept id="c179" label="ChangementRegulierNavire" type="neutral" x="0.0" y="0.0"/>
</concept>
</concept>
<concept id="c150" label="GestionProduction" type="neutral" x="0.0" y="0.0">
<concept id="c151" label="CapacitéTriABord" type="neutral" x="0.0" y="0.0"/>
<concept id="c152" label="UtilisationAppats" type="neutral" x="0.0" y="0.0">
<concept id="c166" label="AppatsCasier" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c153" label="UtilisationVivier" type="neutral" x="0.0" y="0.0">
<concept id="c164" label="TriViviers" type="neutral" x="0.0" y="0.0"/>
<concept id="c165" label="UtilisationVivierCoquille" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c154" label="ValorisationProduction" type="neutral" x="0.0" y="0.0">
<concept id="c159" label="LabellisationProduction" type="neutral" x="0.0" y="0.0">
<concept id="c162" label="EtiquetteBarDeLigne" type="neutral" x="0.0" y="0.0"/>
<concept id="c163" label="EtiquetteHomardCasier" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c160" label="PrendreSoinProduction" type="neutral" x="0.0" y="0.0"/>
<concept id="c161" label="TriProduitsAvantVente" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c155" label="VenteProduction" type="neutral" x="0.0" y="0.0">
<concept id="c156" label="VenteProductionCivelle" type="neutral" x="0.0" y="0.0">
<concept id="c157" label="VenteProductionCivelleRepeuplement" type="neutral" x="0.0" y="0.0"/>
<concept id="c158" label="VenteProductionCivelleConsommation" type="neutral" x="0.0" y="0.0"/>
</concept>
</concept>
</concept>
</concept>
<concept id="c76" label="CircuitDeVente" type="neutral" x="0.0" y="0.0">
<concept id="c136" label="Autres" type="neutral" x="0.0" y="0.0"/>
<concept id="c137" label="Criée" type="neutral" x="0.0" y="0.0">
<concept id="c146" label="CrieeConstruite" type="neutral" x="0.0" y="0.0"/>
<concept id="c147" label="CriéesEnLigne" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c138" label="Grossiste" type="neutral" x="0.0" y="0.0"/>
<concept id="c139" label="Mareyeur" type="neutral" x="0.0" y="0.0">
<concept id="c144" label="MareyeurUnique" type="neutral" x="0.0" y="0.0"/>
<concept id="c145" label="MonopoleMareyeur" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c140" label="Transformateur" type="neutral" x="0.0" y="0.0"/>
<concept id="c141" label="VenteContinent" type="neutral" x="0.0" y="0.0"/>
<concept id="c142" label="VenteDirecte" type="neutral" x="0.0" y="0.0"/>
<concept id="c143" label="VenteIleDYeu" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c77" label="DiminutionVitesse" type="neutral" x="0.0" y="0.0"/>
<concept id="c78" label="DiversificationDeLActivité" type="neutral" x="0.0" y="0.0"/>
<concept id="c79" label="Débarquement" type="neutral" x="0.0" y="0.0">
<concept id="c127" label="DateDebarquement" type="neutral" x="0.0" y="0.0">
<concept id="c134" label="DebarquementAvantLesAutres" type="neutral" x="0.0" y="0.0"/>
<concept id="c135" label="DebarquementCeJour" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c128" label="DébarquementPêcherie" type="neutral" x="0.0" y="0.0">
<concept id="c133" label="DébarquementPêcherieFaible" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c129" label="LieuDebarquement" type="neutral" x="0.0" y="0.0">
<concept id="c130" label="DébarquementMareyeur" type="neutral" x="0.0" y="0.0">
<concept id="c132" label="ChoixMareyeurHonnete" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c131" label="PortDebarquement" type="neutral" x="0.0" y="0.0"/>
</concept>
</concept>
<concept id="c80" label="ExternaliteEconomique" type="neutral" x="0.0" y="0.0">
<concept id="c83" label="AccordCriéeConserverieFlotille" type="neutral" x="0.0" y="0.0"/>
<concept id="c84" label="CoutsDeLaViePlusImportants" type="neutral" x="0.0" y="0.0"/>
<concept id="c85" label="EtatMarche" type="neutral" x="0.0" y="0.0">
<concept id="c106" label="AbsenceAcheteur" type="neutral" x="0.0" y="0.0"/>
<concept id="c107" label="Concurrence" type="neutral" x="0.0" y="0.0">
<concept id="c123" label="AbsenceConcurrence" type="neutral" x="0.0" y="0.0"/>
<concept id="c124" label="FaibleConcurrence" type="neutral" x="0.0" y="0.0"/>
<concept id="c125" label="ForteConcurrence" type="neutral" x="0.0" y="0.0"/>
<concept id="c126" label="PresenceConcurrence" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c108" label="Demande" type="neutral" x="0.0" y="0.0">
<concept id="c120" label="DemandeFaible" type="neutral" x="0.0" y="0.0"/>
<concept id="c121" label="DemandeForte" type="neutral" x="0.0" y="0.0"/>
<concept id="c122" label="DemandeMareyeur" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c109" label="PresenceAcheteur" type="neutral" x="0.0" y="0.0"/>
<concept id="c110" label="PrixMarche" type="neutral" x="0.0" y="0.0">
<concept id="c113" label="PrixCriée" type="neutral" x="0.0" y="0.0">
<concept id="c118" label="DiminutionPrixCriée" type="neutral" x="0.0" y="0.0">
<concept id="c119" label="DiminutionPrixCriéeAuPrintemps" type="neutral" x="0.0" y="0.0"/>
</concept>
</concept>
<concept id="c114" label="PrixFaible" type="neutral" x="0.0" y="0.0"/>
<concept id="c115" label="PrixFort" type="neutral" x="0.0" y="0.0"/>
<concept id="c116" label="PrixMareyeur" type="neutral" x="0.0" y="0.0">
<concept id="c117" label="PrixMareyeurElevés" type="neutral" x="0.0" y="0.0"/>
</concept>
</concept>
<concept id="c111" label="TypeMarche" type="neutral" x="0.0" y="0.0">
<concept id="c112" label="DemandeProduitQualite" type="neutral" x="0.0" y="0.0"/>
</concept>
</concept>
<concept id="c86" label="Inflation" type="neutral" x="0.0" y="0.0"/>
<concept id="c87" label="OpportuniteDAchat" type="neutral" x="0.0" y="0.0">
<concept id="c103" label="OpportuniteDAchatPME" type="neutral" x="0.0" y="0.0"/>
<concept id="c104" label="OpportunitéAchatNavire" type="neutral" x="0.0" y="0.0">
<concept id="c105" label="OpportuniteDAchatDUnNavireModerne" type="neutral" x="0.0" y="0.0"/>
</concept>
</concept>
<concept id="c88" label="PassageDUnNavire" type="neutral" x="0.0" y="0.0">
<concept id="c102" label="PassageDUnChalutierPelagique" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c89" label="PossibiliteFinancement" type="neutral" x="0.0" y="0.0">
<concept id="c98" label="PossibiliteFinancementSeul" type="neutral" x="0.0" y="0.0">
<concept id="c100" label="PossibiliteFinancementSansBanque" type="neutral" x="0.0" y="0.0"/>
<concept id="c101" label="PossibiliteFinancementSansCooperative" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c99" label="PossibiliteFinancementSofipêche" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c90" label="PrixAppat" type="neutral" x="0.0" y="0.0"/>
<concept id="c91" label="PrixCarburant" type="neutral" x="0.0" y="0.0"/>
<concept id="c92" label="PrixVenteFixeAvance" type="neutral" x="0.0" y="0.0"/>
<concept id="c93" label="ProductionFlottille" type="neutral" x="0.0" y="0.0">
<concept id="c94" label="AugmentationProductionFlottille" type="neutral" x="0.0" y="0.0">
<concept id="c97" label="AugmentationProductionFlottillePelagique" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c95" label="DiminutionProductionFlottille" type="neutral" x="0.0" y="0.0">
<concept id="c96" label="DiminutionProductionFlottillePelagique" type="neutral" x="0.0" y="0.0"/>
</concept>
</concept>
</concept>
<concept id="c81" label="Clientèle" type="neutral" x="0.0" y="0.0">
<concept id="c82" label="ClientèleFidélisée" type="neutral" x="0.0" y="0.0"/>
</concept>
</concept>
<concept id="c5" label="Reglement" type="neutral" x="0.0" y="0.0">
<concept id="c41" label="Cantonnement" type="neutral" x="0.0" y="0.0"/>
<concept id="c42" label="FermeturePecherie" type="neutral" x="0.0" y="0.0">
<concept id="c68" label="FermetureAnchois" type="neutral" x="0.0" y="0.0"/>
<concept id="c69" label="FermetureBarEnManche" type="neutral" x="0.0" y="0.0"/>
<concept id="c70" label="FermetureBarGolfeDeGascogne" type="neutral" x="0.0" y="0.0"/>
<concept id="c71" label="FermetureRaieBrunette" type="neutral" x="0.0" y="0.0"/>
<concept id="c72" label="FermetureRequinTaupe" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c43" label="Licence" type="neutral" x="0.0" y="0.0"/>
<concept id="c44" label="NonRespectRéglementation" type="neutral" x="0.0" y="0.0"/>
<concept id="c45" label="Quotas" type="neutral" x="0.0" y="0.0">
<concept id="c54" label="PartageQuotas" type="neutral" x="0.0" y="0.0">
<concept id="c66" label="QuotasIndividuels" type="neutral" x="0.0" y="0.0"/>
<concept id="c67" label="QuotasMutualisés" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c55" label="QuotasEspeces" type="neutral" x="0.0" y="0.0">
<concept id="c58" label="QuotasAnchois" type="neutral" x="0.0" y="0.0"/>
<concept id="c59" label="QuotasCivelle" type="neutral" x="0.0" y="0.0"/>
<concept id="c60" label="QuotasLangoustine" type="neutral" x="0.0" y="0.0"/>
<concept id="c61" label="QuotasSole" type="neutral" x="0.0" y="0.0"/>
<concept id="c62" label="QuotasThon" type="neutral" x="0.0" y="0.0">
<concept id="c65" label="QuotasThonGermon" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c63" label="QuotasMerlan" type="neutral" x="0.0" y="0.0"/>
<concept id="c64" label="QuotasMerlu" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c56" label="AugmentationQuotas" type="neutral" x="0.0" y="0.0"/>
<concept id="c57" label="DiminutionQuotas" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c46" label="ReglementEngin" type="neutral" x="0.0" y="0.0"/>
<concept id="c47" label="RéglementationMoinsDe12m" type="neutral" x="0.0" y="0.0"/>
<concept id="c48" label="TailleMiniCapture" type="neutral" x="0.0" y="0.0"/>
<concept id="c49" label="TempsSortie" type="neutral" x="0.0" y="0.0"/>
<concept id="c50" label="Contrôles" type="neutral" x="0.0" y="0.0">
<concept id="c52" label="ContrôlesEnMer" type="neutral" x="0.0" y="0.0"/>
<concept id="c53" label="ContrôlesAQuai" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c51" label="ReglementationBarProchaine" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c6" label="Temps" type="neutral" x="0.0" y="0.0">
<concept id="c7" label="CalendrierAnnuel" type="neutral" x="0.0" y="0.0">
<concept id="c39" label="CalendierAnnuelFixe" type="neutral" x="0.0" y="0.0"/>
<concept id="c40" label="CalendrierAnnuelAlterne" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c8" label="Campagne" type="neutral" x="0.0" y="0.0"/>
<concept id="c9" label="Epoque" type="neutral" x="0.0" y="0.0">
<concept id="c37" label="EpoqueApresBolincheALaRogue" type="neutral" x="0.0" y="0.0"/>
<concept id="c38" label="EpoquePendantBolincheALaRogue" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c10" label="HeureDeLaJournee" type="neutral" x="0.0" y="0.0"/>
<concept id="c11" label="Jour" type="neutral" x="0.0" y="0.0"/>
<concept id="c12" label="Maree" type="neutral" x="0.0" y="0.0">
<concept id="c33" label="MareeCourte" type="neutral" x="0.0" y="0.0"/>
<concept id="c34" label="MareeHebdomadaire" type="neutral" x="0.0" y="0.0"/>
<concept id="c35" label="MareeJournaliere" type="neutral" x="0.0" y="0.0"/>
<concept id="c36" label="MareeLongue" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c13" label="Nuit" type="neutral" x="0.0" y="0.0"/>
<concept id="c14" label="PêcheHiver" type="neutral" x="0.0" y="0.0"/>
<concept id="c15" label="Saison" type="neutral" x="0.0" y="0.0">
<concept id="c24" label="DébutDeSaison" type="neutral" x="0.0" y="0.0"/>
<concept id="c25" label="SaisonBenthique" type="neutral" x="0.0" y="0.0"/>
<concept id="c26" label="SaisonCrabe" type="neutral" x="0.0" y="0.0"/>
<concept id="c27" label="SaisonCrevette" type="neutral" x="0.0" y="0.0">
<concept id="c32" label="DébutSaisonCrevette" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c28" label="SaisonNonBenthique" type="neutral" x="0.0" y="0.0"/>
<concept id="c29" label="SaisonSeiche" type="neutral" x="0.0" y="0.0">
<concept id="c31" label="SaisonSeicheEte" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c30" label="SaisonCreuse" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c16" label="TempsDeTrajet" type="neutral" x="0.0" y="0.0">
<concept id="c22" label="AugmentationTempsDeTrajet" type="neutral" x="0.0" y="0.0"/>
<concept id="c23" label="DiminutionTempsDeTrajet" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c17" label="TempsEnPeche" type="neutral" x="0.0" y="0.0">
<concept id="c19" label="AugmentationTempsEnPeche" type="neutral" x="0.0" y="0.0">
<concept id="c21" label="AugmentationTempsPecheEnMer" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c20" label="DiminutionTempsEnPeche" type="neutral" x="0.0" y="0.0"/>
</concept>
<concept id="c18" label="ReposHiver" type="neutral" x="0.0" y="0.0"/>
</concept>
</ontologie>
<cartes>
<carte type="attribuée">
<designer nom="LT11" couleur="#debe1f">
<metadata>
<entry key="metier 2" value="aucun"/>
<entry key="taille" value="12"/>
<entry key="metier 3" value="aucun"/>
<entry key="metier 1" value="chalutier de fond"/>
<entry key="port" value="la turballe"/>
<entry key="navire" value="jeanne helene"/>
<entry key="periode" value="2010"/>
</metadata>
</designer>
<concept id="c522" x="673.0" y="168.0"/>
<concept id="c93" x="457.0" y="737.0"/>
<concept id="c395" x="230.0" y="720.0"/>
<concept id="c416" x="299.0" y="407.0"/>
<concept id="c113" x="270.0" y="600.0"/>
<concept id="c50" x="590.0" y="410.0"/>
<concept id="c61" x="109.0" y="427.0"/>
<concept id="c498" x="510.0" y="670.0"/>
<concept id="c122" x="70.0" y="600.0"/>
<concept id="c196" x="387.0" y="502.0"/>
<concept id="c563" x="792.0" y="242.0"/>
<concept id="c567" x="224.0" y="269.0"/>
<concept id="c569" x="400.0" y="270.0"/>
<concept id="c553" x="740.0" y="370.0"/>
<concept id="c244" x="660.0" y="500.0"/>
<concept id="c256" x="170.0" y="490.0"/>
<concept id="c572" x="440.0" y="120.0"/>
<concept id="c270" x="448.0" y="609.0"/>
<concept id="c31" x="450.0" y="379.0"/>
<concept id="c104" x="871.0" y="467.0"/>
<influence from="c270" to="c498" valeur="2"/>
<influence from="c196" to="c270" valeur="4"/>
<influence from="c553" to="c244" valeur="3"/>
<influence from="c572" to="c244" valeur="3"/>
<influence from="c563" to="c522" valeur="3"/>
<influence from="c104" to="c244" valeur="1"/>
<influence from="c122" to="c113" valeur="4"/>
<influence from="c563" to="c553" valeur="4"/>
<influence from="c50" to="c244" valeur="-4"/>
<influence from="c256" to="c196" valeur="3"/>
<influence from="c416" to="c196" valeur="2"/>
<influence from="c572" to="c569" valeur="4"/>
<influence from="c113" to="c196" valeur="4"/>
<influence from="c31" to="c196" valeur="4"/>
<influence from="c93" to="c395" valeur="4"/>
<influence from="c113" to="c395" valeur="4"/>
<influence from="c567" to="c416" valeur="4"/>
<influence from="c569" to="c416" valeur="4"/>
<influence from="c572" to="c567" valeur="4"/>
<influence from="c61" to="c416" valeur="2"/>
</carte>
<carte type="attribuée">
<designer nom="LT12" couleur="#69cdf4">
<metadata>
<entry key="metier 2" value="chalutier de fond en bœuf"/>
<entry key="taille" value="16,5"/>
<entry key="metier 3" value="aucun"/>
<entry key="metier 1" value="chalutier pelagique en bœuf"/>
<entry key="port" value="la turballe"/>
<entry key="navire" value="cintharth"/>
<entry key="periode" value="2010"/>
</metadata>
</designer>
<concept id="c211" x="550.0" y="650.0"/>
<concept id="c113" x="540.0" y="370.0"/>
<concept id="c58" x="194.0" y="476.0"/>
<concept id="c514" x="590.0" y="590.0"/>
<concept id="c30" x="50.0" y="290.0"/>
<concept id="c69" x="510.0" y="240.0"/>
<concept id="c107" x="170.0" y="800.0"/>
<concept id="c411" x="900.0" y="260.0"/>
<concept id="c196" x="490.0" y="540.0"/>
<concept id="c604" x="590.0" y="290.0"/>
<concept id="c419" x="290.0" y="760.0"/>
<concept id="c171" x="310.0" y="820.0"/>
<concept id="c226" x="290.0" y="420.0"/>
<concept id="c272" x="110.0" y="730.0"/>
<concept id="c212" x="40.0" y="240.0"/>
<concept id="c188" x="110.0" y="190.0"/>
<concept id="c417" x="440.0" y="270.0"/>
<concept id="c65" x="120.0" y="670.0"/>
<concept id="c567" x="320.0" y="140.0"/>
<concept id="c472" x="150.0" y="280.0"/>
<concept id="c418" x="400.0" y="570.0"/>
<concept id="c83" x="300.0" y="640.0"/>
<influence from="c113" to="c417" valeur="2"/>
<influence from="c604" to="c417" valeur="2"/>
<influence from="c567" to="c417" valeur="2"/>
<influence from="c196" to="c171" valeur="2"/>
<influence from="c69" to="c417" valeur="-3"/>
<influence from="c113" to="c226" valeur="4"/>
<influence from="c58" to="c226" valeur="3"/>
<influence from="c567" to="c226" valeur="2"/>
<influence from="c65" to="c419" valeur="1"/>
<influence from="c30" to="c472" valeur="4"/>
<influence from="c272" to="c419" valeur="2"/>
<influence from="c58" to="c419" valeur="3"/>
<influence from="c212" to="c472" valeur="2"/>
<influence from="c58" to="c472" valeur="3"/>
<influence from="c188" to="c472" valeur="3"/>
<influence from="c69" to="c411" valeur="3"/>
<influence from="c113" to="c411" valeur="2"/>
<influence from="c107" to="c272" valeur="3"/>
<influence from="c604" to="c411" valeur="2"/>
<influence from="c567" to="c411" valeur="2"/>
<influence from="c514" to="c196" valeur="3"/>
<influence from="c417" to="c196" valeur="3"/>
<influence from="c226" to="c196" valeur="2"/>
<influence from="c411" to="c196" valeur="1"/>
<influence from="c418" to="c196" valeur="1"/>
<influence from="c107" to="c419" valeur="-2"/>
<influence from="c58" to="c418" valeur="4"/>
<influence from="c211" to="c514" valeur="3"/>
<influence from="c83" to="c418" valeur="3"/>
</carte>
<carte type="attribuée">
<designer nom="LT13" couleur="#1fda8f">
<metadata>
<entry key="metier 2" value="civelier"/>
<entry key="taille" value="8"/>
<entry key="metier 3" value="aucun"/>
<entry key="metier 1" value="palangrier"/>
<entry key="port" value="la turballe"/>
<entry key="navire" value="royal"/>
<entry key="periode" value="2010"/>
</metadata>
</designer>
<concept id="c570" x="350.0" y="240.0"/>
<concept id="c380" x="510.0" y="490.0"/>
<concept id="c595" x="60.0" y="280.0"/>
<concept id="c14" x="340.0" y="640.0"/>
<concept id="c473" x="610.0" y="590.0"/>
<concept id="c196" x="310.0" y="460.0"/>
<concept id="c412" x="330.0" y="550.0"/>
<concept id="c517" x="690.0" y="530.0"/>
<concept id="c429" x="440.0" y="410.0"/>
<concept id="c68" x="697.0" y="405.0"/>
<concept id="c472" x="720.0" y="690.0"/>
<concept id="c585" x="500.0" y="340.0"/>
<concept id="c249" x="550.0" y="680.0"/>
<concept id="c154" x="210.0" y="230.0"/>
<concept id="c615" x="162.0" y="559.0"/>
<concept id="c223" x="60.0" y="410.0"/>
<influence from="c615" to="c223" valeur="-4"/>
<influence from="c570" to="c196" valeur="-4"/>
<influence from="c380" to="c412" valeur="4"/>
<influence from="c14" to="c412" valeur="4"/>
<influence from="c412" to="c196" valeur="3"/>
<influence from="c473" to="c517" valeur="4"/>
<influence from="c380" to="c429" valeur="4"/>
<influence from="c595" to="c223" valeur="3"/>
<influence from="c429" to="c196" valeur="4"/>
<influence from="c472" to="c517" valeur="2"/>
<influence from="c154" to="c196" valeur="4"/>
<influence from="c223" to="c196" valeur="4"/>
<influence from="c68" to="c380" valeur="4"/>
<influence from="c585" to="c380" valeur="4"/>
<influence from="c570" to="c585" valeur="4"/>
<influence from="c472" to="c249" valeur="4"/>
<influence from="c517" to="c380" valeur="2"/>
</carte>
<carte type="attribuée">
<designer nom="LS11" couleur="#9e7a2f">
<metadata>
<entry key="metier 2" value="aucun"/>
<entry key="taille" value="10,96"/>
<entry key="metier 3" value="aucun"/>
<entry key="metier 1" value="palangrier"/>
<entry key="port" value="les sables"/>
<entry key="navire" value="mitch"/>
<entry key="periode" value="2010"/>
</metadata>
</designer>
<concept id="c219" x="220.0" y="640.0"/>
<concept id="c265" x="470.0" y="730.0"/>
<concept id="c113" x="320.0" y="400.0"/>
<concept id="c17" x="300.0" y="200.0"/>
<concept id="c58" x="80.0" y="570.0"/>
<concept id="c196" x="420.0" y="460.0"/>
<concept id="c90" x="370.0" y="750.0"/>
<concept id="c579" x="680.0" y="430.0"/>
<concept id="c567" x="469.0" y="344.0"/>
<concept id="c569" x="380.0" y="290.0"/>
<concept id="c611" x="60.0" y="450.0"/>
<concept id="c620" x="190.0" y="280.0"/>
<concept id="c224" x="210.0" y="510.0"/>
<concept id="c215" x="540.0" y="500.0"/>
<concept id="c162" x="700.0" y="630.0"/>
<concept id="c67" x="70.0" y="350.0"/>
<influence from="c90" to="c219" valeur="2"/>
<influence from="c620" to="c67" valeur="-3"/>
<influence from="c265" to="c196" valeur="-3"/>
<influence from="c90" to="c196" valeur="-3"/>
<influence from="c58" to="c224" valeur="4"/>
<influence from="c579" to="c215" valeur="3"/>
<influence from="c620" to="c113" valeur="3"/>
<influence from="c611" to="c67" valeur="4"/>
<influence from="c224" to="c196" valeur="3"/>
<influence from="c215" to="c162" valeur="4"/>
<influence from="c113" to="c196" valeur="4"/>
<influence from="c567" to="c196" valeur="4"/>
<influence from="c569" to="c196" valeur="4"/>
<influence from="c215" to="c196" valeur="4"/>
<influence from="c113" to="c17" valeur="4"/>
</carte>
<carte type="attribuée">
<designer nom="LS12" couleur="#10f829">
<metadata>
<entry key="metier 2" value="aucun"/>
<entry key="taille" value="11,95"/>
<entry key="metier 3" value="aucun"/>
<entry key="metier 1" value="chalutier de fond"/>
<entry key="port" value="les sables"/>
<entry key="navire" value="boxster"/>
<entry key="periode" value="2010"/>
</metadata>
</designer>
<concept id="c395" x="430.0" y="340.0"/>
<concept id="c595" x="280.0" y="320.0"/>
<concept id="c567" x="300.0" y="520.0"/>
<concept id="c569" x="370.0" y="590.0"/>
<concept id="c361" x="130.0" y="700.0"/>
<concept id="c586" x="660.0" y="420.0"/>
<concept id="c539" x="580.0" y="350.0"/>
<concept id="c287" x="710.0" y="580.0"/>
<concept id="c381" x="170.0" y="560.0"/>
<concept id="c215" x="590.0" y="520.0"/>
<concept id="c196" x="440.0" y="420.0"/>
<concept id="c35" x="275.0" y="703.0"/>
<influence from="c395" to="c196" valeur="3"/>
<influence from="c35" to="c381" valeur="4"/>
<influence from="c567" to="c196" valeur="2"/>
<influence from="c569" to="c196" valeur="2"/>
<influence from="c567" to="c381" valeur="3"/>
<influence from="c361" to="c381" valeur="3"/>
<influence from="c586" to="c215" valeur="3"/>
<influence from="c287" to="c215" valeur="3"/>
<influence from="c215" to="c196" valeur="4"/>
<influence from="c196" to="c539" valeur="4"/>
<influence from="c595" to="c395" valeur="3"/>
</carte>
<carte type="attribuée">
<designer nom="LS13" couleur="#a7639a">
<metadata>
<entry key="metier 2" value="aucun"/>
<entry key="taille" value="9,93"/>
<entry key="metier 3" value="aucun"/>
<entry key="metier 1" value="chalutier de fond"/>
<entry key="port" value="les sables"/>
<entry key="navire" value="fille du vent"/>
<entry key="periode" value="2010"/>
</metadata>
</designer>
<concept id="c395" x="395.0" y="299.0"/>
<concept id="c590" x="250.0" y="250.0"/>
<concept id="c79" x="450.0" y="520.0"/>
<concept id="c151" x="430.0" y="420.0"/>
<concept id="c113" x="582.0" y="269.0"/>
<concept id="c592" x="180.0" y="380.0"/>
<concept id="c82" x="110.0" y="620.0"/>
<concept id="c196" x="610.0" y="430.0"/>
<concept id="c604" x="278.0" y="467.0"/>
<concept id="c147" x="747.0" y="251.0"/>
<concept id="c535" x="620.0" y="600.0"/>
<concept id="c585" x="610.0" y="510.0"/>
<concept id="c551" x="230.0" y="700.0"/>
<concept id="c404" x="240.0" y="600.0"/>
<concept id="c311" x="569.0" y="357.0"/>
<influence from="c151" to="c79" valeur="3"/>
<influence from="c592" to="c404" valeur="3"/>
<influence from="c604" to="c404" valeur="3"/>
<influence from="c196" to="c585" valeur="-2"/>
<influence from="c147" to="c113" valeur="3"/>
<influence from="c82" to="c404" valeur="4"/>
<influence from="c79" to="c196" valeur="3"/>
<influence from="c404" to="c551" valeur="4"/>
<influence from="c395" to="c311" valeur="3"/>
<influence from="c113" to="c395" valeur="4"/>
<influence from="c592" to="c395" valeur="4"/>
<influence from="c535" to="c585" valeur="3"/>
<influence from="c151" to="c395" valeur="3"/>
<influence from="c604" to="c395" valeur="3"/>
<influence from="c590" to="c395" valeur="2"/>
</carte>
<carte type="attribuée">
<designer nom="SG11" couleur="#2cac2c">
<metadata>
<entry key="metier 2" value="civelier"/>
<entry key="taille" value="9,2"/>
<entry key="metier 3" value="palangrier"/>
<entry key="metier 1" value="caseyeur"/>
<entry key="port" value="saint gilles croix de vie"/>
<entry key="navire" value="le galejeur"/>
<entry key="periode" value="2010"/>
</metadata>
</designer>
<concept id="c379" x="272.0" y="230.0"/>
<concept id="c403" x="497.0" y="340.0"/>
<concept id="c32" x="580.0" y="530.0"/>
<concept id="c492" x="490.0" y="190.0"/>
<concept id="c14" x="276.0" y="325.0"/>
<concept id="c592" x="170.0" y="510.0"/>
<concept id="c225" x="248.0" y="390.0"/>
<concept id="c196" x="417.0" y="536.0"/>
<concept id="c59" x="130.0" y="458.0"/>
<concept id="c210" x="660.0" y="350.0"/>
<concept id="c35" x="66.0" y="244.0"/>
<concept id="c412" x="390.0" y="260.0"/>
<concept id="c547" x="630.0" y="680.0"/>
<concept id="c272" x="560.0" y="610.0"/>
<concept id="c567" x="610.0" y="240.0"/>
<concept id="c605" x="260.0" y="650.0"/>
<concept id="c560" x="564.0" y="400.0"/>
<influence from="c592" to="c605" valeur="3"/>
<influence from="c492" to="c403" valeur="3"/>
<influence from="c567" to="c403" valeur="3"/>
<influence from="c605" to="c272" valeur="3"/>
<influence from="c403" to="c560" valeur="1"/>
<influence from="c14" to="c412" valeur="3"/>
<influence from="c14" to="c225" valeur="2"/>
<influence from="c492" to="c412" valeur="3"/>
<influence from="c592" to="c225" valeur="2"/>
<influence from="c210" to="c560" valeur="2"/>
<influence from="c32" to="c196" valeur="3"/>
<influence from="c225" to="c196" valeur="3"/>
<influence from="c605" to="c196" valeur="2"/>
<influence from="c272" to="c547" valeur="2"/>
<influence from="c59" to="c225" valeur="-4"/>
<influence from="c35" to="c379" valeur="3"/>
<influence from="c14" to="c379" valeur="4"/>
</carte>
<carte type="attribuée">
<designer nom="SG12" couleur="#befde1">
<metadata>
<entry key="metier 2" value="civelier"/>
<entry key="taille" value="9"/>
<entry key="metier 3" value="aucun"/>
<entry key="metier 1" value="palangrier"/>
<entry key="port" value="saint gilles croix de vie"/>
<entry key="navire" value="ile des jeux ii"/>
<entry key="periode" value="2010"/>
</metadata>
</designer>
<concept id="c415" x="420.0" y="420.0"/>
<concept id="c595" x="90.0" y="570.0"/>
<concept id="c17" x="220.0" y="440.0"/>
<concept id="c225" x="570.0" y="310.0"/>
<concept id="c227" x="270.0" y="550.0"/>
<concept id="c607" x="460.0" y="780.0"/>
<concept id="c122" x="740.0" y="380.0"/>
<concept id="c196" x="420.0" y="510.0"/>
<concept id="c59" x="720.0" y="250.0"/>
<concept id="c564" x="110.0" y="350.0"/>
<concept id="c116" x="680.0" y="460.0"/>
<concept id="c159" x="270.0" y="730.0"/>
<concept id="c608" x="70.0" y="650.0"/>
<concept id="c124" x="430.0" y="330.0"/>
<concept id="c449" x="570.0" y="690.0"/>
<concept id="c535" x="740.0" y="600.0"/>
<concept id="c585" x="610.0" y="610.0"/>
<concept id="c381" x="720.0" y="710.0"/>
<concept id="c215" x="400.0" y="670.0"/>
<concept id="c615" x="300.0" y="200.0"/>
<influence from="c215" to="c159" valeur="4"/>
<influence from="c607" to="c449" valeur="4"/>
<influence from="c215" to="c449" valeur="4"/>
<influence from="c122" to="c225" valeur="4"/>
<influence from="c116" to="c225" valeur="4"/>
<influence from="c615" to="c225" valeur="4"/>
<influence from="c615" to="c227" valeur="-3"/>
<influence from="c608" to="c227" valeur="-2"/>
<influence from="c615" to="c415" valeur="-3"/>
<influence from="c415" to="c196" valeur="3"/>
<influence from="c225" to="c196" valeur="3"/>
<influence from="c227" to="c196" valeur="4"/>
<influence from="c215" to="c196" valeur="4"/>
<influence from="c564" to="c17" valeur="4"/>
<influence from="c17" to="c227" valeur="3"/>
<influence from="c59" to="c225" valeur="-3"/>
<influence from="c124" to="c415" valeur="3"/>
<influence from="c535" to="c585" valeur="4"/>
<influence from="c381" to="c585" valeur="4"/>
<influence from="c449" to="c585" valeur="3"/>
<influence from="c595" to="c227" valeur="4"/>
</carte>
<carte type="attribuée">
<designer nom="SG13" couleur="#10a354">
<metadata>
<entry key="metier 2" value="chalutier de fond"/>
<entry key="taille" value="12"/>
<entry key="metier 3" value="dragueur"/>
<entry key="metier 1" value="chalutier pelagique"/>
<entry key="port" value="saint gilles croix de vie"/>
<entry key="navire" value="l'albi"/>
<entry key="periode" value="2010"/>
</metadata>
</designer>
<concept id="c142" x="470.0" y="370.0"/>
<concept id="c391" x="300.0" y="690.0"/>
<concept id="c113" x="220.0" y="390.0"/>
<concept id="c534" x="350.0" y="120.0"/>
<concept id="c47" x="690.0" y="270.0"/>
<concept id="c14" x="580.0" y="460.0"/>
<concept id="c583" x="460.0" y="120.0"/>
<concept id="c196" x="360.0" y="410.0"/>
<concept id="c35" x="630.0" y="130.0"/>
<concept id="c272" x="180.0" y="230.0"/>
<concept id="c400" x="480.0" y="300.0"/>
<concept id="c567" x="40.0" y="350.0"/>
<concept id="c472" x="320.0" y="590.0"/>
<concept id="c33" x="370.0" y="320.0"/>
<concept id="c418" x="300.0" y="290.0"/>
<concept id="c539" x="440.0" y="470.0"/>
<concept id="c381" x="550.0" y="190.0"/>
<influence from="c47" to="c381" valeur="4"/>
<influence from="c14" to="c400" valeur="4"/>
<influence from="c33" to="c400" valeur="4"/>
<influence from="c381" to="c400" valeur="4"/>
<influence from="c14" to="c472" valeur="4"/>
<influence from="c567" to="c472" valeur="4"/>
<influence from="c400" to="c142" valeur="4"/>
<influence from="c391" to="c472" valeur="3"/>
<influence from="c583" to="c534" valeur="4"/>
<influence from="c196" to="c539" valeur="4"/>
<influence from="c472" to="c196" valeur="3"/>
<influence from="c381" to="c35" valeur="3"/>
<influence from="c381" to="c14" valeur="4"/>
<influence from="c142" to="c196" valeur="4"/>
<influence from="c113" to="c196" valeur="4"/>
<influence from="c272" to="c418" valeur="4"/>
<influence from="c381" to="c418" valeur="4"/>
<influence from="c567" to="c418" valeur="3"/>
<influence from="c33" to="c418" valeur="3"/>
<influence from="c381" to="c583" valeur="4"/>
</carte>
<carte type="attribuée">
<designer nom="SG14" couleur="#743c58">
<metadata>
<entry key="metier 2" value="chalutier de fond"/>
<entry key="taille" value="9,2"/>
<entry key="metier 3" value="civelier"/>
<entry key="metier 1" value="caseyeur"/>
<entry key="port" value="saint gilles croix de vie"/>
<entry key="navire" value="koala ii"/>
<entry key="periode" value="2010"/>
</metadata>
</designer>
<concept id="c219" x="170.0" y="240.0"/>
<concept id="c142" x="350.0" y="410.0"/>
<concept id="c166" x="40.0" y="180.0"/>
<concept id="c492" x="810.0" y="590.0"/>
<concept id="c14" x="630.0" y="670.0"/>
<concept id="c82" x="150.0" y="360.0"/>
<concept id="c196" x="310.0" y="600.0"/>
<concept id="c59" x="490.0" y="730.0"/>
<concept id="c198" x="10.0" y="390.0"/>
<concept id="c21" x="590.0" y="780.0"/>
<concept id="c412" x="380.0" y="770.0"/>
<concept id="c272" x="540.0" y="560.0"/>
<concept id="c212" x="320.0" y="270.0"/>
<concept id="c531" x="370.0" y="370.0"/>
<concept id="c124" x="550.0" y="440.0"/>
<concept id="c429" x="570.0" y="330.0"/>
<concept id="c567" x="740.0" y="380.0"/>
<concept id="c472" x="250.0" y="320.0"/>
<concept id="c137" x="250.0" y="480.0"/>
<concept id="c410" x="540.0" y="490.0"/>
<concept id="c224" x="150.0" y="440.0"/>
<concept id="c407" x="480.0" y="620.0"/>
<influence from="c492" to="c407" valeur="3"/>
<influence from="c272" to="c407" valeur="3"/>
<influence from="c14" to="c407" valeur="2"/>
<influence from="c82" to="c142" valeur="4"/>
<influence from="c224" to="c142" valeur="3"/>
<influence from="c59" to="c21" valeur="-2"/>
<influence from="c492" to="c410" valeur="4"/>
<influence from="c272" to="c410" valeur="4"/>
<influence from="c219" to="c166" valeur="1"/>
<influence from="c124" to="c410" valeur="3"/>
<influence from="c224" to="c137" valeur="3"/>
<influence from="c219" to="c198" valeur="1"/>
<influence from="c472" to="c219" valeur="2"/>
<influence from="c82" to="c472" valeur="3"/>
<influence from="c142" to="c196" valeur="3"/>
<influence from="c412" to="c196" valeur="3"/>
<influence from="c410" to="c196" valeur="3"/>
<influence from="c429" to="c196" valeur="2"/>
<influence from="c137" to="c196" valeur="2"/>
<influence from="c407" to="c196" valeur="2"/>
<influence from="c82" to="c429" valeur="3"/>
<influence from="c198" to="c196" valeur="1"/>
<influence from="c567" to="c429" valeur="3"/>
<influence from="c142" to="c531" valeur="4"/>
<influence from="c492" to="c429" valeur="4"/>
<influence from="c59" to="c412" valeur="-3"/>
<influence from="c472" to="c212" valeur="3"/>
</carte>
<carte type="attribuée">
<designer nom="YE11" couleur="#46f37d">
<metadata>
<entry key="metier 2" value="aucun"/>
<entry key="taille" value="10"/>
<entry key="metier 3" value="aucun"/>
<entry key="metier 1" value="palangrier"/>
<entry key="port" value="port joinville"/>
<entry key="navire" value="barracuda"/>
<entry key="periode" value="2010"/>
</metadata>
</designer>
<concept id="c495" x="640.0" y="40.0"/>
<concept id="c234" x="390.0" y="530.0"/>
<concept id="c251" x="380.0" y="330.0"/>
<concept id="c468" x="370.0" y="110.0"/>
<concept id="c203" x="610.0" y="470.0"/>
<concept id="c196" x="390.0" y="440.0"/>
<concept id="c51" x="580.0" y="600.0"/>
<concept id="c437" x="230.0" y="350.0"/>
<concept id="c449" x="350.0" y="280.0"/>
<concept id="c429" x="634.0" y="218.0"/>
<concept id="c567" x="120.0" y="150.0"/>
<concept id="c436" x="290.0" y="120.0"/>
<concept id="c215" x="20.0" y="340.0"/>
<concept id="c605" x="570.0" y="120.0"/>
<influence from="c449" to="c215" valeur="4"/>
<influence from="c203" to="c234" valeur="4"/>
<influence from="c51" to="c234" valeur="4"/>
<influence from="c449" to="c605" valeur="3"/>
<influence from="c196" to="c234" valeur="2"/>
<influence from="c437" to="c251" valeur="-3"/>
<influence from="c436" to="c449" valeur="4"/>
<influence from="c605" to="c495" valeur="3"/>
<influence from="c468" to="c449" valeur="2"/>
<influence from="c251" to="c449" valeur="2"/>
<influence from="c567" to="c449" valeur="3"/>
<influence from="c215" to="c196" valeur="3"/>
<influence from="c251" to="c196" valeur="1"/>
<influence from="c437" to="c215" valeur="-3"/>
<influence from="c449" to="c429" valeur="4"/>
<influence from="c429" to="c196" valeur="4"/>
</carte>
<carte type="attribuée">
<designer nom="YE12" couleur="#d6615f">
<metadata>
<entry key="metier 2" value="aucun"/>
<entry key="taille" value="10,8"/>
<entry key="metier 3" value="aucun"/>
<entry key="metier 1" value="palangrier"/>
<entry key="port" value="port joinville"/>
<entry key="navire" value="challenger"/>
<entry key="periode" value="2010"/>
</metadata>
</designer>
<concept id="c570" x="642.0" y="240.0"/>
<concept id="c595" x="620.0" y="370.0"/>
<concept id="c484" x="328.0" y="416.0"/>
<concept id="c502" x="497.0" y="27.0"/>
<concept id="c190" x="625.0" y="544.0"/>
<concept id="c227" x="570.0" y="470.0"/>
<concept id="c196" x="441.0" y="488.0"/>
<concept id="c530" x="360.0" y="330.0"/>
<concept id="c35" x="229.0" y="98.0"/>
<concept id="c450" x="510.0" y="290.0"/>
<concept id="c449" x="270.0" y="290.0"/>
<concept id="c567" x="350.0" y="210.0"/>
<concept id="c436" x="170.0" y="380.0"/>
<concept id="c539" x="489.0" y="573.0"/>
<concept id="c360" x="390.0" y="80.0"/>
<concept id="c215" x="90.0" y="280.0"/>
<influence from="c35" to="c360" valeur="2"/>
<influence from="c567" to="c449" valeur="4"/>
<influence from="c196" to="c539" valeur="2"/>
<influence from="c196" to="c190" valeur="2"/>
<influence from="c530" to="c449" valeur="3"/>
<influence from="c436" to="c449" valeur="3"/>
<influence from="c360" to="c449" valeur="3"/>
<influence from="c215" to="c449" valeur="3"/>
<influence from="c484" to="c449" valeur="1"/>
<influence from="c450" to="c196" valeur="3"/>
<influence from="c449" to="c196" valeur="3"/>
<influence from="c227" to="c196" valeur="4"/>
<influence from="c360" to="c502" valeur="4"/>
<influence from="c595" to="c450" valeur="4"/>
<influence from="c570" to="c450" valeur="3"/>
<influence from="c530" to="c450" valeur="3"/>
<influence from="c360" to="c450" valeur="3"/>
<influence from="c595" to="c227" valeur="4"/>
<influence from="c567" to="c450" valeur="1"/>
</carte>
<carte type="attribuée">
<designer nom="YE13" couleur="#099718">
<metadata>
<entry key="metier 2" value="aucun"/>
<entry key="taille" value="23"/>
<entry key="metier 3" value="aucun"/>
<entry key="metier 1" value="fileyeur"/>
<entry key="port" value="port joinville"/>
<entry key="navire" value="aurore boreale"/>
<entry key="periode" value="2010"/>
</metadata>
</designer>
<concept id="c238" x="475.0" y="413.0"/>
<concept id="c558" x="340.0" y="290.0"/>
<concept id="c61" x="58.0" y="439.0"/>
<concept id="c196" x="332.0" y="407.0"/>
<concept id="c530" x="504.0" y="525.0"/>
<concept id="c35" x="630.0" y="370.0"/>
<concept id="c421" x="203.0" y="401.0"/>
<concept id="c542" x="491.0" y="262.0"/>
<concept id="c173" x="310.0" y="100.0"/>
<concept id="c209" x="612.0" y="161.0"/>
<concept id="c359" x="180.0" y="300.0"/>
<concept id="c72" x="138.0" y="510.0"/>
<concept id="c585" x="655.0" y="466.0"/>
<concept id="c528" x="646.0" y="264.0"/>
<concept id="c612" x="58.0" y="365.0"/>
<concept id="c378" x="360.0" y="200.0"/>
<concept id="c215" x="507.0" y="76.0"/>
<concept id="c240" x="90.0" y="210.0"/>
<influence from="c173" to="c215" valeur="4"/>
<influence from="c209" to="c378" valeur="-4"/>
<influence from="c421" to="c196" valeur="3"/>
<influence from="c612" to="c421" valeur="4"/>
<influence from="c530" to="c238" valeur="4"/>
<influence from="c196" to="c238" valeur="3"/>
<influence from="c35" to="c238" valeur="3"/>
<influence from="c585" to="c238" valeur="3"/>
<influence from="c528" to="c35" valeur="4"/>
<influence from="c61" to="c421" valeur="3"/>
<influence from="c72" to="c421" valeur="3"/>
<influence from="c359" to="c378" valeur="1"/>
<influence from="c421" to="c359" valeur="3"/>
<influence from="c240" to="c378" valeur="3"/>
<influence from="c558" to="c378" valeur="4"/>
<influence from="c542" to="c378" valeur="4"/>
<influence from="c173" to="c378" valeur="4"/>
</carte>
<carte type="attribuée">
<designer nom="YE14" couleur="#20c803">
<metadata>
<entry key="metier 2" value="aucun"/>
<entry key="taille" value="18"/>
<entry key="metier 3" value="aucun"/>
<entry key="metier 1" value="fileyeur"/>
<entry key="port" value="port joinville"/>
<entry key="navire" value="p'tit gael ii"/>
<entry key="periode" value="2010"/>
</metadata>
</designer>
<concept id="c64" x="640.0" y="170.0"/>
<concept id="c200" x="511.0" y="69.0"/>
<concept id="c170" x="641.0" y="441.0"/>
<concept id="c385" x="447.0" y="152.0"/>
<concept id="c69" x="92.0" y="283.0"/>
<concept id="c196" x="494.0" y="429.0"/>
<concept id="c299" x="270.0" y="270.0"/>
<concept id="c613" x="10.0" y="383.0"/>
<concept id="c253" x="490.0" y="290.0"/>
<concept id="c624" x="210.0" y="343.0"/>
<concept id="c256" x="320.0" y="50.0"/>
<concept id="c103" x="235.0" y="144.0"/>
<concept id="c270" x="482.0" y="534.0"/>
<concept id="c67" x="340.0" y="550.0"/>
<concept id="c119" x="236.0" y="444.0"/>
<influence from="c385" to="c253" valeur="4"/>
<influence from="c200" to="c385" valeur="4"/>
<influence from="c613" to="c624" valeur="3"/>
<influence from="c103" to="c385" valeur="4"/>
<influence from="c69" to="c624" valeur="4"/>
<influence from="c256" to="c385" valeur="3"/>
<influence from="c64" to="c385" valeur="2"/>
<influence from="c196" to="c270" valeur="2"/>
<influence from="c119" to="c196" valeur="-2"/>
<influence from="c624" to="c119" valeur="2"/>
<influence from="c299" to="c196" valeur="3"/>
<influence from="c67" to="c196" valeur="3"/>
<influence from="c196" to="c170" valeur="2"/>
<influence from="c253" to="c196" valeur="2"/>
<influence from="c624" to="c299" valeur="3"/>
</carte>
<carte type="attribuée">
<designer nom="YE15" couleur="#9789ce">
<metadata>
<entry key="metier 2" value="palangrier"/>
<entry key="taille" value="15"/>
<entry key="metier 3" value="aucun"/>
<entry key="metier 1" value="fileyeur"/>
<entry key="port" value="port joinville"/>
<entry key="navire" value="sherpa"/>
<entry key="periode" value="2010"/>
</metadata>
</designer>
<concept id="c200" x="520.0" y="470.0"/>
<concept id="c425" x="210.0" y="220.0"/>
<concept id="c17" x="310.0" y="180.0"/>
<concept id="c592" x="370.0" y="100.0"/>
<concept id="c196" x="322.0" y="295.0"/>
<concept id="c35" x="241.0" y="487.0"/>
<concept id="c209" x="612.0" y="407.0"/>
<concept id="c567" x="560.0" y="280.0"/>
<concept id="c569" x="130.0" y="340.0"/>
<concept id="c553" x="640.0" y="590.0"/>
<concept id="c500" x="390.0" y="402.0"/>
<concept id="c585" x="590.0" y="530.0"/>
<concept id="c528" x="125.0" y="441.0"/>
<concept id="c423" x="375.0" y="226.0"/>
<concept id="c360" x="454.0" y="179.0"/>
<concept id="c381" x="408.0" y="516.0"/>
<concept id="c626" x="70.0" y="230.0"/>
<influence from="c592" to="c360" valeur="3"/>
<influence from="c585" to="c381" valeur="4"/>
<influence from="c360" to="c423" valeur="3"/>
<influence from="c592" to="c425" valeur="4"/>
<influence from="c17" to="c425" valeur="3"/>
<influence from="c17" to="c423" valeur="4"/>
<influence from="c35" to="c381" valeur="3"/>
<influence from="c567" to="c423" valeur="4"/>
<influence from="c569" to="c423" valeur="4"/>
<influence from="c500" to="c381" valeur="3"/>
<influence from="c585" to="c553" valeur="4"/>
<influence from="c425" to="c196" valeur="2"/>
<influence from="c200" to="c500" valeur="4"/>
<influence from="c209" to="c500" valeur="4"/>
<influence from="c626" to="c425" valeur="-4"/>
<influence from="c567" to="c500" valeur="2"/>
<influence from="c569" to="c500" valeur="2"/>
<influence from="c35" to="c500" valeur="3"/>
<influence from="c528" to="c35" valeur="4"/>
<influence from="c567" to="c196" valeur="4"/>
<influence from="c569" to="c196" valeur="4"/>
<influence from="c423" to="c196" valeur="4"/>
<influence from="c209" to="c585" valeur="4"/>
</carte>
<carte type="attribuée">
<designer nom="LC11" couleur="#caf510">
<metadata>
<entry key="metier 2" value="fileyeur"/>
<entry key="taille" value="9,4"/>
<entry key="metier 3" value="chalutier de fond"/>
<entry key="metier 1" value="caseyeur"/>
<entry key="port" value="le croisic"/>
<entry key="navire" value="den heliga"/>
<entry key="periode" value="2010"/>
</metadata>
</designer>
<concept id="c601" x="500.0" y="380.0"/>
<concept id="c372" x="410.0" y="290.0"/>
<concept id="c190" x="170.0" y="300.0"/>
<concept id="c196" x="50.0" y="300.0"/>
<concept id="c604" x="30.0" y="100.0"/>
<concept id="c57" x="426.0" y="461.0"/>
<concept id="c268" x="180.0" y="430.0"/>
<concept id="c218" x="235.0" y="107.0"/>
<concept id="c569" x="180.0" y="150.0"/>
<concept id="c189" x="724.0" y="264.0"/>
<concept id="c78" x="680.0" y="160.0"/>
<concept id="c84" x="140.0" y="500.0"/>
<concept id="c215" x="20.0" y="400.0"/>
<concept id="c637" x="450.0" y="110.0"/>
<concept id="c605" x="540.0" y="320.0"/>
<concept id="c335" x="427.0" y="186.0"/>
<concept id="c578" x="160.0" y="220.0"/>
<concept id="c623" x="370.0" y="30.0"/>
<concept id="c599" x="550.0" y="210.0"/>
<influence from="c604" to="c218" valeur="4"/>
<influence from="c372" to="c268" valeur="4"/>
<influence from="c84" to="c268" valeur="4"/>
<influence from="c601" to="c605" valeur="4"/>
<influence from="c268" to="c196" valeur="-4"/>
<influence from="c599" to="c605" valeur="4"/>
<influence from="c569" to="c218" valeur="3"/>
<influence from="c372" to="c578" valeur="3"/>
<influence from="c637" to="c78"/>
<influence from="c623" to="c78"/>
<influence from="c599" to="c78"/>
<influence from="c623" to="c604" valeur="-4"/>
<influence from="c196" to="c190" valeur="4"/>
<influence from="c78" to="c189"/>
<influence from="c578" to="c569" valeur="2"/>
<influence from="c604" to="c196" valeur="2"/>
<influence from="c637" to="c335" valeur="3"/>
<influence from="c599" to="c335" valeur="3"/>
<influence from="c57" to="c372" valeur="2"/>
<influence from="c335" to="c372" valeur="3"/>
<influence from="c605" to="c372" valeur="4"/>
<influence from="c599" to="c372" valeur="4"/>
<influence from="c215" to="c196" valeur="4"/>
</carte>
<carte type="attribuée">
<designer nom="LC12" couleur="#0ddf94">
<metadata>
<entry key="metier 2" value="aucun"/>
<entry key="taille" value="12"/>
<entry key="metier 3" value="aucun"/>
<entry key="metier 1" value="caseyeur"/>
<entry key="port" value="le croisic"/>
<entry key="navire" value="atlantide"/>
<entry key="periode" value="2010"/>
</metadata>
</designer>
<concept id="c595" x="484.0" y="610.0"/>
<concept id="c532" x="0.0" y="340.0"/>
<concept id="c534" x="101.0" y="182.0"/>
<concept id="c47" x="181.0" y="122.0"/>
<concept id="c82" x="695.0" y="282.0"/>
<concept id="c229" x="360.0" y="530.0"/>
<concept id="c607" x="571.0" y="139.0"/>
<concept id="c196" x="389.0" y="348.0"/>
<concept id="c35" x="340.0" y="175.0"/>
<concept id="c230" x="600.0" y="532.0"/>
<concept id="c384" x="134.0" y="264.0"/>
<concept id="c446" x="499.0" y="208.0"/>
<concept id="c596" x="252.0" y="516.0"/>
<concept id="c173" x="347.0" y="272.0"/>
<concept id="c369" x="8.0" y="226.0"/>
<concept id="c115" x="339.0" y="451.0"/>
<concept id="c567" x="420.0" y="80.0"/>
<concept id="c215" x="479.0" y="286.0"/>
<concept id="c133" x="491.0" y="462.0"/>
<concept id="c99" x="103.0" y="426.0"/>
<concept id="c163" x="625.0" y="221.0"/>
<concept id="c236" x="611.0" y="376.0"/>
<concept id="c615" x="310.0" y="600.0"/>
<influence from="c615" to="c229" valeur="-4"/>
<influence from="c595" to="c615"/>
<influence from="c163" to="c82" valeur="3"/>
<influence from="c615" to="c230" valeur="4"/>
<influence from="c229" to="c133" valeur="-3"/>
<influence from="c230" to="c133" valeur="-3"/>
<influence from="c163" to="c215" valeur="3"/>
<influence from="c596" to="c115" valeur="4"/>
<influence from="c446" to="c607" valeur="4"/>
<influence from="c615" to="c596" valeur="-3"/>
<influence from="c133" to="c115" valeur="3"/>
<influence from="c534" to="c384" valeur="1"/>
<influence from="c567" to="c446" valeur="3"/>
<influence from="c215" to="c446" valeur="3"/>
<influence from="c173" to="c196" valeur="2"/>
<influence from="c384" to="c173" valeur="2"/>
<influence from="c369" to="c384" valeur="3"/>
<influence from="c99" to="c384" valeur="3"/>
<influence from="c47" to="c384" valeur="4"/>
<influence from="c532" to="c384" valeur="4"/>
<influence from="c35" to="c384" valeur="4"/>
<influence from="c115" to="c196" valeur="4"/>
<influence from="c215" to="c196" valeur="4"/>
<influence from="c196" to="c236" valeur="4"/>
</carte>
<carte type="attribuée">
<designer nom="SN11" couleur="#b759f6">
<metadata>
<entry key="metier 2" value="civelier"/>
<entry key="taille" value="8,36"/>
<entry key="metier 3" value="aucun"/>
<entry key="metier 1" value="chalutier de fond"/>
<entry key="port" value="saint nazaire"/>
<entry key="navire" value="lea flora"/>
<entry key="periode" value="2010"/>
</metadata>
</designer>
<concept id="c616" x="100.0" y="490.0"/>
<concept id="c157" x="470.0" y="300.0"/>
<concept id="c595" x="70.0" y="440.0"/>
<concept id="c144" x="180.0" y="300.0"/>
<concept id="c225" x="400.0" y="430.0"/>
<concept id="c467" x="10.0" y="10.0"/>
<concept id="c196" x="294.0" y="147.0"/>
<concept id="c59" x="520.0" y="360.0"/>
<concept id="c116" x="390.0" y="60.0"/>
<concept id="c373" x="20.0" y="50.0"/>
<concept id="c412" x="333.0" y="66.0"/>
<concept id="c408" x="80.0" y="210.0"/>
<concept id="c164" x="460.0" y="20.0"/>
<concept id="c158" x="170.0" y="370.0"/>
<concept id="c567" x="150.0" y="67.0"/>
<concept id="c612" x="520.0" y="500.0"/>
<concept id="c256" x="500.0" y="220.0"/>
<concept id="c496" x="246.0" y="10.0"/>
<concept id="c24" x="290.0" y="310.0"/>
<concept id="c215" x="590.0" y="170.0"/>
<concept id="c77" x="670.0" y="330.0"/>
<influence from="c77" to="c215" valeur="4"/>
<influence from="c24" to="c157" valeur="3"/>
<influence from="c24" to="c158" valeur="4"/>
<influence from="c59" to="c77" valeur="4"/>
<influence from="c408" to="c144" valeur="4"/>
<influence from="c158" to="c144" valeur="4"/>
<influence from="c77" to="c256" valeur="4"/>
<influence from="c567" to="c412" valeur="4"/>
<influence from="c496" to="c412" valeur="4"/>
<influence from="c595" to="c225" valeur="4"/>
<influence from="c467" to="c408" valeur="3"/>
<influence from="c59" to="c225" valeur="4"/>
<influence from="c373" to="c408" valeur="3"/>
<influence from="c164" to="c116"/>
<influence from="c24" to="c225" valeur="4"/>
<influence from="c595" to="c408" valeur="4"/>
<influence from="c567" to="c408" valeur="4"/>
<influence from="c616" to="c225" valeur="2"/>
<influence from="c225" to="c196" valeur="3"/>
<influence from="c412" to="c196" valeur="3"/>
<influence from="c215" to="c196" valeur="3"/>
<influence from="c157" to="c196" valeur="2"/>
<influence from="c408" to="c196" valeur="2"/>
<influence from="c256" to="c196" valeur="2"/>
<influence from="c612" to="c59" valeur="1"/>
<influence from="c116" to="c196" valeur="4"/>
<influence from="c158" to="c196" valeur="4"/>
</carte>
<carte type="attribuée">
<designer nom="SN12" couleur="#8eae1a">
<metadata>
<entry key="metier 2" value="aucun"/>
<entry key="taille" value="10"/>
<entry key="metier 3" value="aucun"/>
<entry key="metier 1" value="chalutier de fond"/>
<entry key="port" value="saint nazaire"/>
<entry key="navire" value="le petrel"/>
<entry key="periode" value="2010"/>
</metadata>
</designer>
<concept id="c271" x="580.0" y="490.0"/>
<concept id="c18" x="366.0" y="450.0"/>
<concept id="c19" x="538.0" y="435.0"/>
<concept id="c610" x="188.0" y="111.0"/>
<concept id="c61" x="32.0" y="242.0"/>
<concept id="c196" x="317.0" y="267.0"/>
<concept id="c228" x="153.0" y="196.0"/>
<concept id="c517" x="550.0" y="590.0"/>
<concept id="c507" x="174.0" y="455.0"/>
<concept id="c567" x="500.0" y="111.0"/>
<concept id="c174" x="580.0" y="340.0"/>
<concept id="c535" x="470.0" y="260.0"/>
<concept id="c472" x="561.0" y="167.0"/>
<concept id="c585" x="459.0" y="356.0"/>
<concept id="c614" x="60.0" y="370.0"/>
<concept id="c485" x="472.0" y="526.0"/>
<concept id="c221" x="227.0" y="348.0"/>
<influence from="c174" to="c472" valeur="4"/>
<influence from="c567" to="c472" valeur="4"/>
<influence from="c614" to="c507" valeur="3"/>
<influence from="c19" to="c585" valeur="-3"/>
<influence from="c18" to="c19" valeur="4"/>
<influence from="c61" to="c228" valeur="1"/>
<influence from="c614" to="c18" valeur="-1"/>
<influence from="c221" to="c18" valeur="-4"/>
<influence from="c228" to="c196" valeur="4"/>
<influence from="c614" to="c221" valeur="4"/>
<influence from="c585" to="c196" valeur="4"/>
<influence from="c221" to="c196" valeur="4"/>
<influence from="c517" to="c485" valeur="4"/>
<influence from="c610" to="c228" valeur="-4"/>
<influence from="c485" to="c18" valeur="3"/>
<influence from="c535" to="c585" valeur="3"/>
<influence from="c174" to="c585" valeur="3"/>
<influence from="c585" to="c18" valeur="4"/>
<influence from="c271" to="c485" valeur="3"/>
</carte>
<carte type="attribuée">
<designer nom="LH11" couleur="#0c5253">
<metadata>
<entry key="metier 2" value="fileyeur"/>
<entry key="taille" value="9"/>
<entry key="metier 3" value="civelier"/>
<entry key="metier 1" value="palangrier"/>
<entry key="port" value="noirmoutier"/>
<entry key="navire" value="angele"/>
<entry key="periode" value="2010"/>
</metadata>
</designer>
<concept id="c219" x="580.0" y="430.0"/>
<concept id="c71" x="110.0" y="199.0"/>
<concept id="c595" x="380.0" y="400.0"/>
<concept id="c379" x="194.0" y="456.0"/>
<concept id="c59" x="150.0" y="350.0"/>
<concept id="c413" x="100.0" y="260.0"/>
<concept id="c35" x="96.0" y="487.0"/>
<concept id="c437" x="323.0" y="406.0"/>
<concept id="c446" x="110.0" y="320.0"/>
<concept id="c596" x="470.0" y="380.0"/>
<concept id="c212" x="260.0" y="290.0"/>
<concept id="c115" x="600.0" y="290.0"/>
<concept id="c449" x="480.0" y="316.0"/>
<concept id="c567" x="350.0" y="490.0"/>
<influence from="c212" to="c413" valeur="1"/>
<influence from="c595" to="c219" valeur="4"/>
<influence from="c379" to="c437" valeur="2"/>
<influence from="c219" to="c449" valeur="4"/>
<influence from="c212" to="c437" valeur="1"/>
<influence from="c212" to="c449" valeur="3"/>
<influence from="c449" to="c115" valeur="3"/>
<influence from="c596" to="c449" valeur="1"/>
<influence from="c567" to="c437" valeur="4"/>
<influence from="c212" to="c446" valeur="1"/>
<influence from="c71" to="c212" valeur="4"/>
<influence from="c595" to="c212" valeur="4"/>
<influence from="c59" to="c212" valeur="4"/>
<influence from="c379" to="c212" valeur="3"/>
<influence from="c35" to="c379" valeur="4"/>
<influence from="c595" to="c596" valeur="4"/>
</carte>
<carte type="attribuée">
<designer nom="LH12" couleur="#75c0d8">
<metadata>
<entry key="metier 2" value="caseyeur"/>
<entry key="taille" value="12"/>
<entry key="metier 3" value="fileyeur"/>
<entry key="metier 1" value="palangrier"/>
<entry key="port" value="noirmoutier"/>
<entry key="navire" value="p'tit père charles"/>
<entry key="periode" value="2010"/>
</metadata>
</designer>
<concept id="c570" x="90.0" y="230.0"/>
<concept id="c501" x="330.0" y="280.0"/>
<concept id="c54" x="292.0" y="68.0"/>
<concept id="c61" x="200.0" y="128.0"/>
<concept id="c35" x="86.0" y="311.0"/>
<concept id="c450" x="450.0" y="220.0"/>
<concept id="c446" x="620.0" y="330.0"/>
<concept id="c209" x="431.0" y="476.0"/>
<concept id="c212" x="310.0" y="170.0"/>
<concept id="c449" x="240.0" y="290.0"/>
<concept id="c360" x="580.0" y="420.0"/>
<concept id="c381" x="395.0" y="412.0"/>
<concept id="c215" x="200.0" y="390.0"/>
<concept id="c605" x="540.0" y="270.0"/>
<influence from="c209" to="c381" valeur="4"/>
<influence from="c449" to="c381" valeur="4"/>
<influence from="c61" to="c54" valeur="2"/>
<influence from="c450" to="c605" valeur="3"/>
<influence from="c360" to="c381" valeur="3"/>
<influence from="c212" to="c449" valeur="2"/>
<influence from="c570" to="c449" valeur="3"/>
<influence from="c35" to="c449" valeur="3"/>
<influence from="c215" to="c449" valeur="3"/>
<influence from="c61" to="c570" valeur="2"/>
<influence from="c450" to="c501" valeur="4"/>
<influence from="c449" to="c501" valeur="4"/>
<influence from="c605" to="c446" valeur="4"/>
<influence from="c360" to="c450" valeur="4"/>
<influence from="c61" to="c212" valeur="4"/>
<influence from="c54" to="c212" valeur="2"/>
<influence from="c212" to="c450" valeur="1"/>
</carte>
<carte type="attribuée">
<designer nom="LH13" couleur="#57f445">
<metadata>
<entry key="metier 2" value="caseyeur"/>
<entry key="taille" value="9,85"/>
<entry key="metier 3" value="civelier"/>
<entry key="metier 1" value="fileyeur"/>
<entry key="port" value="noirmoutier"/>
<entry key="navire" value="fleur oceane"/>
<entry key="periode" value="2010"/>
</metadata>
</designer>
<concept id="c71" x="630.0" y="180.0"/>
<concept id="c595" x="71.0" y="174.0"/>
<concept id="c211" x="168.0" y="524.0"/>
<concept id="c196" x="380.0" y="390.0"/>
<concept id="c35" x="70.0" y="36.0"/>
<concept id="c412" x="150.0" y="300.0"/>
<concept id="c212" x="270.0" y="190.0"/>
<concept id="c429" x="210.0" y="290.0"/>
<concept id="c567" x="380.0" y="250.0"/>
<concept id="c174" x="480.0" y="420.0"/>
<concept id="c535" x="606.0" y="530.0"/>
<concept id="c585" x="440.0" y="500.0"/>
<concept id="c410" x="540.0" y="240.0"/>
<concept id="c397" x="40.0" y="340.0"/>
<concept id="c381" x="100.0" y="128.0"/>
<concept id="c428" x="310.0" y="290.0"/>
<influence from="c35" to="c381" valeur="4"/>
<influence from="c212" to="c428" valeur="4"/>
<influence from="c567" to="c428" valeur="2"/>
<influence from="c212" to="c412" valeur="4"/>
<influence from="c212" to="c397" valeur="4"/>
<influence from="c429" to="c196" valeur="3"/>
<influence from="c410" to="c196" valeur="3"/>
<influence from="c397" to="c196" valeur="3"/>
<influence from="c71" to="c410" valeur="4"/>
<influence from="c212" to="c410" valeur="4"/>
<influence from="c585" to="c196" valeur="2"/>
<influence from="c412" to="c196" valeur="1"/>
<influence from="c212" to="c429" valeur="4"/>
<influence from="c567" to="c410" valeur="3"/>
<influence from="c428" to="c196" valeur="4"/>
<influence from="c211" to="c585" valeur="4"/>
<influence from="c585" to="c535" valeur="4"/>
<influence from="c585" to="c174" valeur="4"/>
<influence from="c381" to="c212" valeur="4"/>
<influence from="c595" to="c212" valeur="3"/>
<influence from="c196" to="c174" valeur="3"/>
</carte>
<carte type="attribuée">
<designer nom="PB11" couleur="#0419f8">
<metadata>
<entry key="metier 2" value="civelier"/>
<entry key="taille" value="8,3"/>
<entry key="metier 3" value="aucun"/>
<entry key="metier 1" value="fileyeur"/>
<entry key="port" value="noirmoutier"/>
<entry key="navire" value="zebulon"/>
<entry key="periode" value="2010"/>
</metadata>
</designer>
<concept id="c44" x="20.0" y="601.0"/>
<concept id="c639" x="680.0" y="90.0"/>
<concept id="c69" x="360.0" y="560.0"/>
<concept id="c604" x="470.0" y="100.0"/>
<concept id="c426" x="480.0" y="200.0"/>
<concept id="c456" x="230.0" y="340.0"/>
<concept id="c598" x="566.0" y="37.0"/>
<concept id="c458" x="600.0" y="236.0"/>
<concept id="c125" x="30.0" y="510.0"/>
<concept id="c397" x="240.0" y="280.0"/>
<concept id="c215" x="690.0" y="290.0"/>
<concept id="c501" x="530.0" y="450.0"/>
<concept id="c19" x="200.0" y="420.0"/>
<concept id="c275" x="170.0" y="520.0"/>
<concept id="c167" x="70.0" y="130.0"/>
<concept id="c324" x="630.0" y="410.0"/>
<concept id="c187" x="510.0" y="400.0"/>
<concept id="c196" x="305.0" y="360.0"/>
<concept id="c35" x="260.0" y="80.0"/>
<concept id="c609" x="169.0" y="333.0"/>
<concept id="c412" x="20.0" y="390.0"/>
<concept id="c212" x="367.0" y="134.0"/>
<concept id="c483" x="610.0" y="130.0"/>
<concept id="c567" x="640.0" y="190.0"/>
<concept id="c535" x="40.0" y="40.0"/>
<concept id="c585" x="180.0" y="30.0"/>
<concept id="c381" x="343.0" y="32.0"/>
<concept id="c428" x="440.0" y="340.0"/>
<concept id="c623" x="420.0" y="480.0"/>
<influence from="c397" to="c456" valeur="4"/>
<influence from="c35" to="c381" valeur="4"/>
<influence from="c585" to="c381" valeur="4"/>
<influence from="c609" to="c397" valeur="-3"/>
<influence from="c125" to="c275" valeur="4"/>
<influence from="c458" to="c324" valeur="4"/>
<influence from="c212" to="c397" valeur="3"/>
<influence from="c598" to="c604" valeur="4"/>
<influence from="c567" to="c458" valeur="4"/>
<influence from="c458" to="c428" valeur="4"/>
<influence from="c212" to="c428" valeur="3"/>
<influence from="c19" to="c196" valeur="-3"/>
<influence from="c215" to="c458" valeur="3"/>
<influence from="c501" to="c458" valeur="3"/>
<influence from="c598" to="c483" valeur="4"/>
<influence from="c585" to="c167" valeur="4"/>
<influence from="c458" to="c187" valeur="3"/>
<influence from="c275" to="c19" valeur="4"/>
<influence from="c212" to="c412" valeur="3"/>
<influence from="c275" to="c412" valeur="1"/>
<influence from="c412" to="c196" valeur="3"/>
<influence from="c428" to="c196" valeur="3"/>
<influence from="c623" to="c428" valeur="-3"/>
<influence from="c458" to="c426" valeur="4"/>
<influence from="c397" to="c196" valeur="1"/>
<influence from="c604" to="c426" valeur="3"/>
<influence from="c212" to="c426" valeur="3"/>
<influence from="c483" to="c426" valeur="3"/>
<influence from="c44" to="c125" valeur="4"/>
<influence from="c426" to="c196" valeur="4"/>
<influence from="c125" to="c412" valeur="-4"/>
<influence from="c35" to="c585" valeur="4"/>
<influence from="c535" to="c585" valeur="4"/>
<influence from="c69" to="c623" valeur="4"/>
<influence from="c381" to="c212" valeur="4"/>
</carte>
<carte type="attribuée">
<designer nom="LC01" couleur="#326bed">
<metadata>
<entry key="metier 2" value="aucun"/>
<entry key="taille" value="15,5"/>
<entry key="metier 3" value="aucun"/>
<entry key="metier 1" value="caseyeur"/>
<entry key="port" value="le croisic"/>
<entry key="navire" value="les trois freres"/>
<entry key="periode" value="1970"/>
</metadata>
</designer>
<concept id="c172" x="300.0" y="570.0"/>
<concept id="c26" x="621.0" y="265.0"/>
<concept id="c196" x="309.0" y="384.0"/>
<concept id="c566" x="450.0" y="549.0"/>
<concept id="c507" x="603.0" y="360.0"/>
<concept id="c579" x="420.0" y="270.0"/>
<concept id="c115" x="124.0" y="476.0"/>
<concept id="c121" x="64.0" y="543.0"/>
<concept id="c27" x="710.0" y="210.0"/>
<concept id="c569" x="627.0" y="521.0"/>
<concept id="c169" x="268.0" y="473.0"/>
<concept id="c577" x="540.0" y="614.0"/>
<concept id="c506" x="410.0" y="160.0"/>
<concept id="c615" x="102.0" y="280.0"/>
<influence from="c196" to="c507" valeur="4"/>
<influence from="c579" to="c507" valeur="4"/>
<influence from="c506" to="c507" valeur="4"/>
<influence from="c566" to="c172" valeur="4"/>
<influence from="c615" to="c196" valeur="-4"/>
<influence from="c172" to="c169" valeur="4"/>
<influence from="c27" to="c507" valeur="2"/>
<influence from="c121" to="c115" valeur="4"/>
<influence from="c577" to="c566" valeur="4"/>
<influence from="c26" to="c506" valeur="4"/>
<influence from="c196" to="c506" valeur="4"/>
<influence from="c579" to="c196" valeur="2"/>
<influence from="c577" to="c569" valeur="3"/>
<influence from="c26" to="c507" valeur="-4"/>
<influence from="c27" to="c506" valeur="3"/>
<influence from="c566" to="c196" valeur="4"/>
<influence from="c115" to="c196" valeur="4"/>
<influence from="c569" to="c196" valeur="4"/>
<influence from="c169" to="c196" valeur="4"/>
</carte>
<carte type="attribuée">
<designer nom="LC05" couleur="#a5365a">
<metadata>
<entry key="metier 2" value="dragueur"/>
<entry key="taille" value="15,2"/>
<entry key="metier 3" value="aucun"/>
<entry key="metier 1" value="caseyeur"/>
<entry key="port" value="le croisic"/>
<entry key="navire" value="le gaston maryline"/>
<entry key="periode" value="1970"/>
</metadata>
</designer>
<concept id="c372" x="600.0" y="140.0"/>
<concept id="c584" x="117.0" y="387.0"/>
<concept id="c196" x="297.0" y="361.0"/>
<concept id="c542" x="440.0" y="575.0"/>
<concept id="c446" x="80.0" y="120.0"/>
<concept id="c628" x="459.0" y="368.0"/>
<concept id="c302" x="487.0" y="262.0"/>
<concept id="c214" x="177.0" y="256.0"/>
<concept id="c33" x="109.0" y="182.0"/>
<concept id="c370" x="363.0" y="453.0"/>
<concept id="c235" x="216.0" y="519.0"/>
<concept id="c360" x="203.0" y="117.0"/>
<concept id="c215" x="335.0" y="196.0"/>
<concept id="c276" x="640.0" y="363.0"/>
<influence from="c33" to="c214" valeur="4"/>
<influence from="c370" to="c196" valeur="3"/>
<influence from="c360" to="c33" valeur="4"/>
<influence from="c302" to="c196" valeur="2"/>
<influence from="c215" to="c196" valeur="2"/>
<influence from="c628" to="c196" valeur="1"/>
<influence from="c628" to="c542" valeur="2"/>
<influence from="c372" to="c302" valeur="3"/>
<influence from="c196" to="c584" valeur="3"/>
<influence from="c370" to="c542" valeur="4"/>
<influence from="c235" to="c542" valeur="4"/>
<influence from="c446" to="c33" valeur="3"/>
<influence from="c214" to="c196" valeur="4"/>
<influence from="c235" to="c370" valeur="2"/>
<influence from="c276" to="c628" valeur="2"/>
</carte>
<carte type="attribuée">
<designer nom="LC06" couleur="#b5dee4">
<metadata>
<entry key="metier 2" value="aucun"/>
<entry key="taille" value="7,5"/>
<entry key="metier 3" value="aucun"/>
<entry key="metier 1" value="caseyeur"/>
<entry key="port" value="le croisic"/>
<entry key="navire" value="le cassiopee"/>
<entry key="periode" value="1970"/>
</metadata>
</designer>
<concept id="c161" x="34.0" y="206.0"/>
<concept id="c497" x="147.0" y="421.0"/>
<concept id="c631" x="240.0" y="290.0"/>
<concept id="c534" x="304.0" y="462.0"/>
<concept id="c281" x="562.0" y="336.0"/>
<concept id="c196" x="380.0" y="250.0"/>
<concept id="c247" x="320.0" y="420.0"/>
<concept id="c178" x="656.0" y="123.0"/>
<concept id="c446" x="208.0" y="249.0"/>
<concept id="c250" x="513.0" y="400.0"/>
<concept id="c576" x="240.0" y="160.0"/>
<concept id="c134" x="340.0" y="30.0"/>
<concept id="c33" x="121.0" y="321.0"/>
<concept id="c636" x="510.0" y="200.0"/>
<concept id="c323" x="255.0" y="341.0"/>
<concept id="c360" x="591.0" y="489.0"/>
<concept id="c215" x="122.0" y="124.0"/>
<concept id="c216" x="248.0" y="76.0"/>
<concept id="c221" x="472.0" y="79.0"/>
<concept id="c176" x="633.0" y="258.0"/>
<influence from="c161" to="c215" valeur="4"/>
<influence from="c534" to="c497" valeur="4"/>
<influence from="c178" to="c636" valeur="-4"/>
<influence from="c33" to="c497" valeur="4"/>
<influence from="c636" to="c196" valeur="-4"/>
<influence from="c176" to="c636" valeur="-4"/>
<influence from="c247" to="c534" valeur="4"/>
<influence from="c323" to="c631" valeur="3"/>
<influence from="c631" to="c196" valeur="3"/>
<influence from="c247" to="c196" valeur="3"/>
<influence from="c446" to="c33" valeur="4"/>
<influence from="c576" to="c196" valeur="3"/>
<influence from="c576" to="c446" valeur="3"/>
<influence from="c134" to="c221" valeur="3"/>
<influence from="c281" to="c250" valeur="4"/>
<influence from="c360" to="c250" valeur="4"/>
<influence from="c250" to="c196" valeur="4"/>
<influence from="c216" to="c221" valeur="4"/>
<influence from="c221" to="c196" valeur="4"/>
<influence from="c215" to="c216" valeur="2"/>
</carte>
<carte type="attribuée">
<designer nom="LC07" couleur="#505f4f">
<metadata>
<entry key="metier 2" value="dragueur"/>
<entry key="taille" value="10,5"/>
<entry key="metier 3" value="aucun"/>
<entry key="metier 1" value="chalutier de fond"/>
<entry key="port" value="le croisic"/>
<entry key="navire" value="l'aventurier"/>
<entry key="periode" value="1970"/>
</metadata>
</designer>
<concept id="c315" x="49.0" y="247.0"/>
<concept id="c497" x="20.0" y="340.0"/>
<concept id="c364" x="590.0" y="90.0"/>
<concept id="c288" x="240.0" y="480.0"/>
<concept id="c172" x="358.0" y="134.0"/>
<concept id="c165" x="100.0" y="400.0"/>
<concept id="c583" x="410.0" y="280.0"/>
<concept id="c283" x="390.0" y="360.0"/>
<concept id="c196" x="315.0" y="315.0"/>
<concept id="c543" x="38.0" y="177.0"/>
<concept id="c400" x="162.0" y="278.0"/>
<concept id="c286" x="450.0" y="420.0"/>
<concept id="c23" x="560.0" y="470.0"/>
<concept id="c169" x="287.0" y="209.0"/>
<concept id="c496" x="51.0" y="487.0"/>
<concept id="c215" x="220.0" y="360.0"/>
<concept id="c432" x="220.0" y="557.0"/>
<concept id="c243" x="110.0" y="180.0"/>
<concept id="c221" x="466.0" y="197.0"/>
<concept id="c627" x="450.0" y="90.0"/>
<concept id="c615" x="323.0" y="420.0"/>
<influence from="c627" to="c172" valeur="2"/>
<influence from="c196" to="c497" valeur="3"/>
<influence from="c315" to="c497" valeur="4"/>
<influence from="c288" to="c215" valeur="3"/>
<influence from="c165" to="c215" valeur="3"/>
<influence from="c315" to="c543" valeur="-3"/>
<influence from="c172" to="c169" valeur="3"/>
<influence from="c283" to="c196" valeur="-4"/>
<influence from="c627" to="c196" valeur="-3"/>
<influence from="c364" to="c627" valeur="2"/>
<influence from="c364" to="c23" valeur="4"/>
<influence from="c497" to="c496" valeur="2"/>
<influence from="c172" to="c196" valeur="3"/>
<influence from="c583" to="c196" valeur="3"/>
<influence from="c400" to="c196" valeur="3"/>
<influence from="c169" to="c196" valeur="3"/>
<influence from="c243" to="c196" valeur="3"/>
<influence from="c364" to="c221" valeur="2"/>
<influence from="c286" to="c221" valeur="2"/>
<influence from="c215" to="c196" valeur="2"/>
<influence from="c432" to="c496" valeur="3"/>
<influence from="c432" to="c23" valeur="2"/>
<influence from="c221" to="c196" valeur="4"/>
<influence from="c615" to="c283" valeur="2"/>
<influence from="c288" to="c286" valeur="2"/>
</carte>
<carte type="attribuée">
<designer nom="LC08" couleur="#82eb4e">
<metadata>
<entry key="metier 2" value="palangrier"/>
<entry key="taille" value="8,5"/>
<entry key="metier 3" value="civelier"/>
<entry key="metier 1" value="caseyeur"/>
<entry key="port" value="le croisic"/>
<entry key="navire" value="le recif"/>
<entry key="periode" value="1970"/>
</metadata>
</designer>
<concept id="c303" x="150.0" y="290.0"/>
<concept id="c372" x="51.0" y="358.0"/>
<concept id="c160" x="633.0" y="177.0"/>
<concept id="c196" x="388.0" y="201.0"/>
<concept id="c35" x="642.0" y="256.0"/>
<concept id="c321" x="501.0" y="316.0"/>
<concept id="c412" x="240.0" y="360.0"/>
<concept id="c621" x="361.0" y="519.0"/>
<concept id="c359" x="397.0" y="374.0"/>
<concept id="c272" x="433.0" y="418.0"/>
<concept id="c213" x="58.0" y="227.0"/>
<concept id="c168" x="262.0" y="89.0"/>
<concept id="c208" x="80.0" y="87.0"/>
<concept id="c567" x="541.0" y="406.0"/>
<concept id="c635" x="258.0" y="435.0"/>
<concept id="c215" x="522.0" y="241.0"/>
<concept id="c221" x="374.0" y="139.0"/>
<concept id="c615" x="170.0" y="505.0"/>
<influence from="c160" to="c215" valeur="4"/>
<influence from="c35" to="c215" valeur="4"/>
<influence from="c635" to="c196" valeur="-4"/>
<influence from="c372" to="c213" valeur="3"/>
<influence from="c635" to="c412" valeur="4"/>
<influence from="c272" to="c321" valeur="2"/>
<influence from="c567" to="c321" valeur="2"/>
<influence from="c208" to="c168" valeur="3"/>
<influence from="c303" to="c196" valeur="3"/>
<influence from="c213" to="c196" valeur="3"/>
<influence from="c215" to="c196" valeur="3"/>
<influence from="c221" to="c196" valeur="3"/>
<influence from="c168" to="c221" valeur="1"/>
<influence from="c372" to="c303" valeur="3"/>
<influence from="c321" to="c196" valeur="4"/>
<influence from="c412" to="c196" valeur="4"/>
<influence from="c321" to="c359" valeur="3"/>
<influence from="c615" to="c635" valeur="1"/>
<influence from="c621" to="c635" valeur="4"/>
</carte>
<carte type="attribuée">
<designer nom="LS01" couleur="#bd237d">
<metadata>
<entry key="metier 2" value="thonier"/>
<entry key="taille" value="18"/>
<entry key="metier 3" value="aucun"/>
<entry key="metier 1" value="chalutier de fond"/>
<entry key="port" value="les sables"/>
<entry key="navire" value="le magnifique"/>
<entry key="periode" value="1970"/>
</metadata>
</designer>
<concept id="c94" x="340.0" y="470.0"/>
<concept id="c254" x="402.0" y="306.0"/>
<concept id="c325" x="362.0" y="49.0"/>
<concept id="c534" x="244.0" y="172.0"/>
<concept id="c25" x="630.0" y="70.0"/>
<concept id="c196" x="641.0" y="357.0"/>
<concept id="c135" x="440.0" y="370.0"/>
<concept id="c546" x="140.0" y="280.0"/>
<concept id="c34" x="202.0" y="344.0"/>
<concept id="c253" x="512.0" y="141.0"/>
<concept id="c419" x="690.0" y="250.0"/>
<concept id="c628" x="357.0" y="120.0"/>
<concept id="c576" x="140.0" y="106.0"/>
<concept id="c115" x="420.0" y="530.0"/>
<concept id="c505" x="69.0" y="395.0"/>
<concept id="c386" x="395.0" y="588.0"/>
<concept id="c33" x="317.0" y="403.0"/>
<concept id="c360" x="436.0" y="216.0"/>
<concept id="c577" x="20.0" y="180.0"/>
<concept id="c432" x="45.0" y="300.0"/>
<concept id="c615" x="310.0" y="260.0"/>
<influence from="c419" to="c253" valeur="4"/>
<influence from="c628" to="c253" valeur="4"/>
<influence from="c628" to="c534" valeur="4"/>
<influence from="c432" to="c534" valeur="4"/>
<influence from="c419" to="c254" valeur="2"/>
<influence from="c546" to="c534" valeur="3"/>
<influence from="c432" to="c34" valeur="4"/>
<influence from="c34" to="c546" valeur="2"/>
<influence from="c615" to="c33" valeur="2"/>
<influence from="c432" to="c505" valeur="2"/>
<influence from="c94" to="c115" valeur="-2"/>
<influence from="c577" to="c576" valeur="1"/>
<influence from="c615" to="c534" valeur="-4"/>
<influence from="c34" to="c254" valeur="-2"/>
<influence from="c360" to="c254" valeur="-2"/>
<influence from="c432" to="c386" valeur="4"/>
<influence from="c25" to="c419" valeur="4"/>
<influence from="c576" to="c325" valeur="4"/>
<influence from="c386" to="c196" valeur="2"/>
<influence from="c33" to="c135" valeur="4"/>
<influence from="c94" to="c135" valeur="3"/>
<influence from="c254" to="c196" valeur="4"/>
<influence from="c253" to="c196" valeur="4"/>
<influence from="c419" to="c196" valeur="4"/>
<influence from="c628" to="c196" valeur="4"/>
<influence from="c115" to="c196" valeur="4"/>
<influence from="c577" to="c432" valeur="2"/>
<influence from="c325" to="c628" valeur="2"/>
</carte>
<carte type="attribuée">
<designer nom="LS02" couleur="#91e0ee">
<metadata>
<entry key="metier 2" value="aucun"/>
<entry key="taille" value="13,8"/>
<entry key="metier 3" value="aucun"/>
<entry key="metier 1" value="chalutier de fond"/>
<entry key="port" value="les sables"/>
<entry key="navire" value="le vierge du salut"/>
<entry key="periode" value="1970"/>
</metadata>
</designer>
<concept id="c465" x="590.0" y="380.0"/>
<concept id="c262" x="526.0" y="244.0"/>
<concept id="c579" x="85.0" y="282.0"/>
<concept id="c567" x="52.0" y="390.0"/>
<concept id="c263" x="547.0" y="317.0"/>
<concept id="c170" x="81.0" y="490.0"/>
<concept id="c279" x="274.0" y="482.0"/>
<concept id="c215" x="221.0" y="196.0"/>
<concept id="c196" x="364.0" y="293.0"/>
<concept id="c552" x="489.0" y="453.0"/>
<concept id="c221" x="226.0" y="368.0"/>
<influence from="c579" to="c215" valeur="4"/>
<influence from="c579" to="c221" valeur="3"/>
<influence from="c567" to="c170" valeur="3"/>
<influence from="c170" to="c221" valeur="3"/>
<influence from="c279" to="c221" valeur="2"/>
<influence from="c263" to="c196" valeur="-3"/>
<influence from="c262" to="c196" valeur="-2"/>
<influence from="c567" to="c221" valeur="4"/>
<influence from="c215" to="c196" valeur="4"/>
<influence from="c221" to="c196" valeur="4"/>
<influence from="c465" to="c552" valeur="3"/>
<influence from="c579" to="c567" valeur="3"/>
</carte>
<carte type="attribuée">
<designer nom="LS04" couleur="#7598ce">
<metadata>
<entry key="metier 2" value="aucun"/>
<entry key="taille" value="17"/>
<entry key="metier 3" value="aucun"/>
<entry key="metier 1" value="chalutier de fond"/>
<entry key="port" value="les sables"/>
<entry key="navire" value="le petit fatras"/>
<entry key="periode" value="1970"/>
</metadata>
</designer>
<concept id="c364" x="463.0" y="264.0"/>
<concept id="c534" x="616.0" y="104.0"/>
<concept id="c545" x="330.0" y="321.0"/>
<concept id="c241" x="294.0" y="103.0"/>
<concept id="c13" x="322.0" y="597.0"/>
<concept id="c477" x="524.0" y="598.0"/>
<concept id="c565" x="20.0" y="120.0"/>
<concept id="c527" x="480.0" y="20.0"/>
<concept id="c508" x="206.0" y="312.0"/>
<concept id="c101" x="90.0" y="170.0"/>
<concept id="c215" x="570.0" y="230.0"/>
<concept id="c526" x="137.0" y="40.0"/>
<concept id="c293" x="552.0" y="468.0"/>
<concept id="c94" x="88.0" y="439.0"/>
<concept id="c275" x="197.0" y="526.0"/>
<concept id="c388" x="416.0" y="592.0"/>
<concept id="c105" x="38.0" y="72.0"/>
<concept id="c584" x="693.0" y="279.0"/>
<concept id="c196" x="411.0" y="436.0"/>
<concept id="c231" x="470.0" y="330.0"/>
<concept id="c115" x="291.0" y="401.0"/>
<concept id="c579" x="641.0" y="329.0"/>
<concept id="c91" x="692.0" y="402.0"/>
<concept id="c149" x="424.0" y="530.0"/>
<concept id="c409" x="320.0" y="220.0"/>
<concept id="c577" x="70.0" y="230.0"/>
<concept id="c249" x="542.0" y="401.0"/>
<influence from="c115" to="c231" valeur="2"/>
<influence from="c215" to="c231" valeur="3"/>
<influence from="c534" to="c215" valeur="2"/>
<influence from="c584" to="c215" valeur="2"/>
<influence from="c579" to="c215" valeur="2"/>
<influence from="c409" to="c241" valeur="4"/>
<influence from="c565" to="c241" valeur="3"/>
<influence from="c527" to="c241" valeur="3"/>
<influence from="c526" to="c241" valeur="3"/>
<influence from="c105" to="c241" valeur="3"/>
<influence from="c101" to="c241" valeur="2"/>
<influence from="c241" to="c534" valeur="2"/>
<influence from="c94" to="c275" valeur="1"/>
<influence from="c94" to="c115" valeur="-1"/>
<influence from="c545" to="c409" valeur="3"/>
<influence from="c13" to="c388" valeur="-1"/>
<influence from="c577" to="c409" valeur="3"/>
<influence from="c477" to="c293" valeur="1"/>
<influence from="c91" to="c249" valeur="4"/>
<influence from="c364" to="c545" valeur="3"/>
<influence from="c508" to="c545" valeur="3"/>
<influence from="c249" to="c196" valeur="-1"/>
<influence from="c409" to="c364" valeur="4"/>
<influence from="c231" to="c196" valeur="3"/>
<influence from="c388" to="c477" valeur="-1"/>
<influence from="c149" to="c196" valeur="2"/>
<influence from="c293" to="c196" valeur="1"/>
<influence from="c275" to="c196" valeur="1"/>
</carte>
<carte type="attribuée">
<designer nom="LS06" couleur="#1404f1">
<metadata>
<entry key="metier 2" value="aucun"/>
<entry key="taille" value="20,5"/>
<entry key="metier 3" value="aucun"/>
<entry key="metier 1" value="chalutier pelagique en bœuf"/>
<entry key="port" value="les sables"/>
<entry key="navire" value="le mendiant de l'ocean"/>
<entry key="periode" value="1970"/>
</metadata>
</designer>
<concept id="c364" x="114.0" y="75.0"/>
<concept id="c238" x="280.0" y="250.0"/>
<concept id="c534" x="60.0" y="550.0"/>
<concept id="c294" x="470.0" y="470.0"/>
<concept id="c179" x="20.0" y="380.0"/>
<concept id="c196" x="567.0" y="87.0"/>
<concept id="c247" x="171.0" y="468.0"/>
<concept id="c542" x="52.0" y="306.0"/>
<concept id="c525" x="194.0" y="411.0"/>
<concept id="c478" x="210.0" y="164.0"/>
<concept id="c213" x="341.0" y="119.0"/>
<concept id="c212" x="346.0" y="50.0"/>
<concept id="c628" x="690.0" y="530.0"/>
<concept id="c569" x="470.0" y="260.0"/>
<concept id="c33" x="738.0" y="138.0"/>
<concept id="c296" x="504.0" y="405.0"/>
<concept id="c554" x="267.0" y="329.0"/>
<concept id="c215" x="711.0" y="33.0"/>
<influence from="c525" to="c179" valeur="3"/>
<influence from="c478" to="c213" valeur="3"/>
<influence from="c569" to="c213" valeur="3"/>
<influence from="c33" to="c215" valeur="2"/>
<influence from="c364" to="c213" valeur="2"/>
<influence from="c179" to="c534" valeur="3"/>
<influence from="c478" to="c364" valeur="4"/>
<influence from="c628" to="c534" valeur="3"/>
<influence from="c213" to="c196" valeur="3"/>
<influence from="c628" to="c196" valeur="3"/>
<influence from="c212" to="c196" valeur="2"/>
<influence from="c296" to="c569" valeur="3"/>
<influence from="c215" to="c196" valeur="2"/>
<influence from="c179" to="c542" valeur="2"/>
<influence from="c294" to="c296" valeur="3"/>
<influence from="c478" to="c238" valeur="3"/>
<influence from="c525" to="c247" valeur="4"/>
<influence from="c247" to="c569" valeur="4"/>
<influence from="c525" to="c478" valeur="3"/>
<influence from="c364" to="c212" valeur="3"/>
<influence from="c238" to="c554" valeur="4"/>
<influence from="c569" to="c628" valeur="3"/>
<influence from="c247" to="c628" valeur="2"/>
</carte>
<carte type="attribuée">
<designer nom="LS07" couleur="#226d8a">
<metadata>
<entry key="metier 2" value="aucun"/>
<entry key="taille" value="12"/>
<entry key="metier 3" value="aucun"/>
<entry key="metier 1" value="chalutier de fond"/>
<entry key="port" value="les sables"/>
<entry key="navire" value="le dominique magalie"/>
<entry key="periode" value="1970"/>
</metadata>
</designer>
<concept id="c630" x="507.0" y="254.0"/>
<concept id="c231" x="273.0" y="121.0"/>
<concept id="c288" x="31.0" y="217.0"/>
<concept id="c567" x="610.0" y="180.0"/>
<concept id="c160" x="124.0" y="257.0"/>
<concept id="c185" x="497.0" y="396.0"/>
<concept id="c215" x="124.0" y="126.0"/>
<concept id="c196" x="510.0" y="113.0"/>
<concept id="c542" x="245.0" y="397.0"/>
<concept id="c216" x="286.0" y="233.0"/>
<concept id="c276" x="656.0" y="287.0"/>
<influence from="c231" to="c196" valeur="3"/>
<influence from="c630" to="c196" valeur="3"/>
<influence from="c567" to="c196" valeur="3"/>
<influence from="c185" to="c542" valeur="4"/>
<influence from="c216" to="c231" valeur="2"/>
<influence from="c215" to="c231" valeur="3"/>
<influence from="c288" to="c215" valeur="3"/>
<influence from="c160" to="c215" valeur="3"/>
<influence from="c276" to="c567" valeur="2"/>
<influence from="c185" to="c630" valeur="3"/>
<influence from="c215" to="c216" valeur="2"/>
</carte>
<carte type="attribuée">
<designer nom="LS08" couleur="#98423b">
<metadata>
<entry key="metier 2" value="aucun"/>
<entry key="taille" value="16"/>
<entry key="metier 3" value="aucun"/>
<entry key="metier 1" value="chalutier de fond"/>
<entry key="port" value="les sables"/>
<entry key="navire" value="le petit caprice"/>
<entry key="periode" value="1970"/>
</metadata>
</designer>
<concept id="c634" x="419.0" y="187.0"/>
<concept id="c497" x="36.0" y="201.0"/>
<concept id="c558" x="251.0" y="445.0"/>
<concept id="c514" x="215.0" y="347.0"/>
<concept id="c196" x="440.0" y="300.0"/>
<concept id="c247" x="340.0" y="370.0"/>
<concept id="c542" x="30.0" y="290.0"/>
<concept id="c282" x="600.0" y="400.0"/>
<concept id="c272" x="638.0" y="145.0"/>
<concept id="c576" x="290.0" y="100.0"/>
<concept id="c246" x="555.0" y="468.0"/>
<concept id="c150" x="150.0" y="270.0"/>
<concept id="c297" x="560.0" y="300.0"/>
<concept id="c472" x="52.0" y="131.0"/>
<concept id="c559" x="328.0" y="549.0"/>
<concept id="c528" x="37.0" y="58.0"/>
<concept id="c215" x="280.0" y="237.0"/>
<concept id="c577" x="550.0" y="40.0"/>
<concept id="c216" x="208.0" y="301.0"/>
<concept id="c311" x="630.0" y="220.0"/>
<influence from="c472" to="c497" valeur="3"/>
<influence from="c246" to="c282" valeur="3"/>
<influence from="c246" to="c559" valeur="4"/>
<influence from="c576" to="c215" valeur="3"/>
<influence from="c150" to="c215" valeur="3"/>
<influence from="c282" to="c297" valeur="4"/>
<influence from="c576" to="c542" valeur="4"/>
<influence from="c282" to="c247" valeur="4"/>
<influence from="c246" to="c247" valeur="4"/>
<influence from="c577" to="c576" valeur="4"/>
<influence from="c528" to="c472" valeur="4"/>
<influence from="c634" to="c196" valeur="-4"/>
<influence from="c576" to="c472" valeur="2"/>
<influence from="c272" to="c311" valeur="4"/>
<influence from="c576" to="c311" valeur="4"/>
<influence from="c297" to="c311" valeur="4"/>
<influence from="c215" to="c196" valeur="3"/>
<influence from="c216" to="c196" valeur="2"/>
<influence from="c542" to="c558" valeur="4"/>
<influence from="c246" to="c558" valeur="4"/>
<influence from="c514" to="c196" valeur="4"/>
<influence from="c247" to="c196" valeur="4"/>
<influence from="c282" to="c196" valeur="4"/>
<influence from="c297" to="c196" valeur="4"/>
<influence from="c311" to="c196" valeur="4"/>
<influence from="c558" to="c514" valeur="4"/>
<influence from="c215" to="c216" valeur="4"/>
</carte>
<carte type="attribuée">
<designer nom="SG01" couleur="#624c1e">
<metadata>
<entry key="metier 2" value="thonier"/>
<entry key="taille" value="20,6"/>
<entry key="metier 3" value="aucun"/>
<entry key="metier 1" value="chalutier de fond "/>
<entry key="port" value="saint gilles croix de vie"/>
<entry key="navire" value="le melpomene"/>
<entry key="periode" value="1970"/>
</metadata>
</designer>
<concept id="c510" x="677.0" y="129.0"/>
<concept id="c92" x="380.0" y="100.0"/>
<concept id="c305" x="265.0" y="375.0"/>
<concept id="c424" x="43.0" y="206.0"/>
<concept id="c371" x="677.0" y="415.0"/>
<concept id="c496" x="89.0" y="91.0"/>
<concept id="c196" x="392.0" y="212.0"/>
<concept id="c542" x="360.0" y="550.0"/>
<concept id="c276" x="173.0" y="265.0"/>
<concept id="c221" x="320.0" y="290.0"/>
<concept id="c240" x="100.0" y="460.0"/>
<influence from="c424" to="c92" valeur="4"/>
<influence from="c92" to="c510" valeur="3"/>
<influence from="c424" to="c276" valeur="4"/>
<influence from="c92" to="c196" valeur="3"/>
<influence from="c240" to="c371" valeur="4"/>
<influence from="c240" to="c542" valeur="2"/>
<influence from="c424" to="c240" valeur="4"/>
<influence from="c424" to="c496" valeur="4"/>
<influence from="c276" to="c305" valeur="4"/>
<influence from="c305" to="c221" valeur="4"/>
<influence from="c424" to="c196" valeur="4"/>
<influence from="c371" to="c196" valeur="4"/>
<influence from="c221" to="c196" valeur="4"/>
</carte>
<carte type="attribuée">
<designer nom="SG02" couleur="#85ea03">
<metadata>
<entry key="metier 2" value="aucun"/>
<entry key="taille" value="12"/>
<entry key="metier 3" value="aucun"/>
<entry key="metier 1" value="chalutier de fond"/>
<entry key="port" value="saint gilles croix de vie"/>
<entry key="navire" value="l'odyssee"/>
<entry key="periode" value="1970"/>
</metadata>
</designer>
<concept id="c300" x="32.0" y="232.0"/>
<concept id="c172" x="160.0" y="34.0"/>
<concept id="c303" x="150.0" y="254.0"/>
<concept id="c372" x="37.0" y="327.0"/>
<concept id="c534" x="692.0" y="511.0"/>
<concept id="c584" x="663.0" y="438.0"/>
<concept id="c196" x="479.0" y="307.0"/>
<concept id="c525" x="34.0" y="106.0"/>
<concept id="c272" x="357.0" y="485.0"/>
<concept id="c628" x="434.0" y="560.0"/>
<concept id="c567" x="270.0" y="100.0"/>
<concept id="c302" x="190.0" y="360.0"/>
<concept id="c33" x="724.0" y="58.0"/>
<concept id="c215" x="530.0" y="60.0"/>
<concept id="c216" x="580.0" y="260.0"/>
<concept id="c243" x="126.0" y="531.0"/>
<concept id="c311" x="409.0" y="185.0"/>
<concept id="c221" x="227.0" y="184.0"/>
<concept id="c112" x="670.0" y="210.0"/>
<influence from="c172" to="c215" valeur="4"/>
<influence from="c33" to="c215" valeur="4"/>
<influence from="c112" to="c215" valeur="4"/>
<influence from="c525" to="c172" valeur="4"/>
<influence from="c567" to="c172" valeur="4"/>
<influence from="c311" to="c215" valeur="3"/>
<influence from="c372" to="c300" valeur="3"/>
<influence from="c372" to="c302" valeur="3"/>
<influence from="c534" to="c584" valeur="2"/>
<influence from="c196" to="c584" valeur="2"/>
<influence from="c272" to="c628" valeur="-2"/>
<influence from="c243" to="c272" valeur="2"/>
<influence from="c311" to="c221" valeur="3"/>
<influence from="c272" to="c221" valeur="2"/>
<influence from="c628" to="c196" valeur="2"/>
<influence from="c216" to="c196" valeur="2"/>
<influence from="c372" to="c303" valeur="3"/>
<influence from="c172" to="c221" valeur="4"/>
<influence from="c300" to="c221" valeur="4"/>
<influence from="c303" to="c221" valeur="4"/>
<influence from="c567" to="c311" valeur="3"/>
<influence from="c302" to="c221" valeur="4"/>
<influence from="c215" to="c196" valeur="4"/>
<influence from="c221" to="c196" valeur="4"/>
<influence from="c215" to="c216" valeur="4"/>
<influence from="c243" to="c628" valeur="3"/>
</carte>
<carte type="attribuée">
<designer nom="SG03" couleur="#c97d68">
<metadata>
<entry key="metier 2" value="aucun"/>
<entry key="taille" value="18"/>
<entry key="metier 3" value="aucun"/>
<entry key="metier 1" value="chalutier pelagique en bœuf"/>
<entry key="port" value="saint gilles croix de vie"/>
<entry key="navire" value="le dionysos"/>
<entry key="periode" value="1970"/>
</metadata>
</designer>
<concept id="c630" x="560.0" y="179.0"/>
<concept id="c590" x="80.0" y="413.0"/>
<concept id="c10" x="206.0" y="336.0"/>
<concept id="c592" x="58.0" y="485.0"/>
<concept id="c473" x="537.0" y="413.0"/>
<concept id="c196" x="380.0" y="320.0"/>
<concept id="c564" x="242.0" y="78.0"/>
<concept id="c308" x="250.0" y="470.0"/>
<concept id="c111" x="204.0" y="605.0"/>
<concept id="c250" x="530.0" y="310.0"/>
<concept id="c569" x="223.0" y="196.0"/>
<concept id="c503" x="624.0" y="568.0"/>
<concept id="c33" x="546.0" y="495.0"/>
<concept id="c235" x="640.0" y="140.0"/>
<concept id="c248" x="512.0" y="79.0"/>
<concept id="c15" x="92.0" y="547.0"/>
<concept id="c215" x="393.0" y="480.0"/>
<concept id="c186" x="722.0" y="437.0"/>
<concept id="c577" x="54.0" y="107.0"/>
<concept id="c311" x="411.0" y="551.0"/>
<influence from="c33" to="c215" valeur="4"/>
<influence from="c630" to="c196" valeur="3"/>
<influence from="c308" to="c196" valeur="3"/>
<influence from="c308" to="c311" valeur="4"/>
<influence from="c250" to="c196" valeur="3"/>
<influence from="c577" to="c569" valeur="3"/>
<influence from="c630" to="c250" valeur="2"/>
<influence from="c473" to="c250" valeur="2"/>
<influence from="c33" to="c503" valeur="3"/>
<influence from="c235" to="c248" valeur="3"/>
<influence from="c564" to="c569" valeur="4"/>
<influence from="c473" to="c33" valeur="3"/>
<influence from="c569" to="c196" valeur="4"/>
<influence from="c33" to="c311" valeur="3"/>
<influence from="c248" to="c196" valeur="4"/>
<influence from="c215" to="c196" valeur="4"/>
<influence from="c186" to="c630" valeur="2"/>
<influence from="c235" to="c630" valeur="3"/>
<influence from="c33" to="c186" valeur="2"/>
<influence from="c590" to="c308" valeur="3"/>
<influence from="c10" to="c308" valeur="3"/>
<influence from="c592" to="c308" valeur="3"/>
<influence from="c111" to="c308" valeur="3"/>
<influence from="c15" to="c308" valeur="3"/>
</carte>
<carte type="attribuée">
<designer nom="SG04" couleur="#e11d33">
<metadata>
<entry key="metier 2" value="aucun"/>
<entry key="taille" value="13,5"/>
<entry key="metier 3" value="aucun"/>
<entry key="metier 1" value="chalutier de fond"/>
<entry key="port" value="saint gilles croix de vie"/>
<entry key="navire" value="le flibustier"/>
<entry key="periode" value="1970"/>
</metadata>
</designer>
<concept id="c239" x="173.0" y="279.0"/>
<concept id="c285" x="143.0" y="173.0"/>
<concept id="c120" x="99.0" y="505.0"/>
<concept id="c19" x="593.0" y="421.0"/>
<concept id="c196" x="569.0" y="345.0"/>
<concept id="c95" x="506.0" y="33.0"/>
<concept id="c490" x="383.0" y="93.0"/>
<concept id="c359" x="415.0" y="535.0"/>
<concept id="c430" x="410.0" y="410.0"/>
<concept id="c115" x="550.0" y="117.0"/>
<concept id="c36" x="310.0" y="210.0"/>
<concept id="c214" x="680.0" y="300.0"/>
<concept id="c33" x="748.0" y="496.0"/>
<concept id="c513" x="20.0" y="280.0"/>
<concept id="c185" x="238.0" y="556.0"/>
<concept id="c508" x="110.0" y="370.0"/>
<concept id="c533" x="317.0" y="149.0"/>
<concept id="c221" x="410.0" y="260.0"/>
<concept id="c615" x="300.0" y="38.0"/>
<influence from="c33" to="c214" valeur="3"/>
<influence from="c19" to="c196" valeur="-2"/>
<influence from="c513" to="c239" valeur="3"/>
<influence from="c359" to="c19" valeur="1"/>
<influence from="c285" to="c533" valeur="3"/>
<influence from="c33" to="c19" valeur="3"/>
<influence from="c490" to="c533" valeur="4"/>
<influence from="c95" to="c115" valeur="3"/>
<influence from="c508" to="c239" valeur="4"/>
<influence from="c115" to="c196" valeur="3"/>
<influence from="c239" to="c36" valeur="3"/>
<influence from="c430" to="c196" valeur="4"/>
<influence from="c36" to="c221" valeur="4"/>
<influence from="c214" to="c196" valeur="4"/>
<influence from="c533" to="c221" valeur="4"/>
<influence from="c221" to="c196" valeur="4"/>
<influence from="c239" to="c285" valeur="3"/>
<influence from="c359" to="c430" valeur="4"/>
<influence from="c615" to="c285" valeur="3"/>
<influence from="c120" to="c185" valeur="3"/>
<influence from="c615" to="c95" valeur="3"/>
<influence from="c239" to="c359" valeur="4"/>
</carte>
<carte type="attribuée">
<designer nom="SG05" couleur="#6b9967">
<metadata>
<entry key="metier 2" value="peche promenade"/>
<entry key="taille" value="12"/>
<entry key="metier 3" value="aucun"/>
<entry key="metier 1" value="caseyeur "/>
<entry key="port" value="saint gilles croix de vie"/>
<entry key="navire" value="l'ami du pecheur"/>
<entry key="periode" value="1970"/>
</metadata>
</designer>
<concept id="c497" x="680.0" y="447.0"/>
<concept id="c584" x="219.0" y="523.0"/>
<concept id="c196" x="420.0" y="152.0"/>
<concept id="c35" x="497.0" y="440.0"/>
<concept id="c549" x="0.0" y="130.0"/>
<concept id="c446" x="410.0" y="390.0"/>
<concept id="c231" x="566.0" y="270.0"/>
<concept id="c193" x="110.0" y="150.0"/>
<concept id="c272" x="110.0" y="350.0"/>
<concept id="c507" x="251.0" y="69.0"/>
<concept id="c579" x="138.0" y="476.0"/>
<concept id="c134" x="655.0" y="360.0"/>
<concept id="c567" x="305.0" y="501.0"/>
<concept id="c189" x="50.0" y="40.0"/>
<concept id="c215" x="480.0" y="363.0"/>
<concept id="c276" x="30.0" y="420.0"/>
<concept id="c311" x="276.0" y="394.0"/>
<concept id="c221" x="250.0" y="280.0"/>
<concept id="c615" x="220.0" y="210.0"/>
<influence from="c35" to="c215" valeur="4"/>
<influence from="c446" to="c215" valeur="4"/>
<influence from="c189" to="c507" valeur="4"/>
<influence from="c215" to="c231" valeur="4"/>
<influence from="c189" to="c193" valeur="4"/>
<influence from="c311" to="c193" valeur="4"/>
<influence from="c35" to="c497" valeur="4"/>
<influence from="c134" to="c231" valeur="2"/>
<influence from="c189" to="c549" valeur="4"/>
<influence from="c584" to="c311" valeur="4"/>
<influence from="c272" to="c311" valeur="4"/>
<influence from="c579" to="c311" valeur="4"/>
<influence from="c567" to="c311" valeur="4"/>
<influence from="c276" to="c311" valeur="4"/>
<influence from="c446" to="c221" valeur="4"/>
<influence from="c231" to="c196" valeur="4"/>
<influence from="c193" to="c196" valeur="4"/>
<influence from="c311" to="c221" valeur="4"/>
<influence from="c221" to="c196" valeur="4"/>
<influence from="c615" to="c221" valeur="4"/>
</carte>
<carte type="attribuée">
<designer nom="SG06" couleur="#4ea9d4">
<metadata>
<entry key="metier 2" value="caseyeur"/>
<entry key="taille" value="8"/>
<entry key="metier 3" value="civelier"/>
<entry key="metier 1" value="chalutier de fond"/>
<entry key="port" value="saint gilles croix de vie"/>
<entry key="navire" value="le saute mouton"/>
<entry key="periode" value="1970"/>
</metadata>
</designer>
<concept id="c245" x="471.0" y="570.0"/>
<concept id="c372" x="592.0" y="93.0"/>
<concept id="c379" x="80.0" y="250.0"/>
<concept id="c196" x="670.0" y="280.0"/>
<concept id="c552" x="459.0" y="453.0"/>
<concept id="c542" x="422.0" y="293.0"/>
<concept id="c576" x="0.0" y="140.0"/>
<concept id="c208" x="343.0" y="395.0"/>
<concept id="c302" x="653.0" y="193.0"/>
<concept id="c360" x="260.0" y="250.0"/>
<concept id="c100" x="57.0" y="392.0"/>
<concept id="c215" x="693.0" y="442.0"/>
<concept id="c577" x="160.0" y="100.0"/>
<influence from="c379" to="c360" valeur="4"/>
<influence from="c245" to="c196" valeur="3"/>
<influence from="c208" to="c196" valeur="3"/>
<influence from="c215" to="c196" valeur="2"/>
<influence from="c208" to="c542" valeur="3"/>
<influence from="c360" to="c542" valeur="4"/>
<influence from="c372" to="c302" valeur="2"/>
<influence from="c302" to="c196" valeur="4"/>
<influence from="c100" to="c379" valeur="2"/>
<influence from="c576" to="c379" valeur="4"/>
<influence from="c208" to="c552" valeur="-3"/>
<influence from="c577" to="c379" valeur="4"/>
<influence from="c245" to="c552" valeur="-2"/>
</carte>
<carte type="attribuée">
<designer nom="YE01" couleur="#934260">
<metadata>
<entry key="metier 2" value="thonier"/>
<entry key="taille" value="20"/>
<entry key="metier 3" value="aucun"/>
<entry key="metier 1" value="fileyeur"/>
<entry key="port" value="port joinville"/>
<entry key="navire" value="le verseau"/>
<entry key="periode" value="1970"/>
</metadata>
</designer>
<concept id="c622" x="43.0" y="265.0"/>
<concept id="c184" x="683.0" y="109.0"/>
<concept id="c534" x="714.0" y="288.0"/>
<concept id="c196" x="260.0" y="356.0"/>
<concept id="c259" x="430.0" y="340.0"/>
<concept id="c437" x="706.0" y="377.0"/>
<concept id="c282" x="253.0" y="173.0"/>
<concept id="c277" x="482.0" y="87.0"/>
<concept id="c269" x="447.0" y="218.0"/>
<concept id="c290" x="319.0" y="578.0"/>
<concept id="c579" x="54.0" y="460.0"/>
<concept id="c246" x="690.0" y="200.0"/>
<concept id="c256" x="440.0" y="400.0"/>
<concept id="c185" x="57.0" y="359.0"/>
<concept id="c629" x="316.0" y="493.0"/>
<concept id="c544" x="48.0" y="118.0"/>
<influence from="c277" to="c184" valeur="4"/>
<influence from="c437" to="c256" valeur="3"/>
<influence from="c277" to="c282" valeur="4"/>
<influence from="c622" to="c196" valeur="-4"/>
<influence from="c437" to="c534" valeur="4"/>
<influence from="c437" to="c269" valeur="2"/>
<influence from="c246" to="c269" valeur="2"/>
<influence from="c437" to="c290" valeur="4"/>
<influence from="c277" to="c269" valeur="4"/>
<influence from="c629" to="c196" valeur="3"/>
<influence from="c290" to="c629" valeur="3"/>
<influence from="c259" to="c196" valeur="4"/>
<influence from="c282" to="c196" valeur="4"/>
<influence from="c269" to="c196" valeur="4"/>
<influence from="c579" to="c196" valeur="4"/>
<influence from="c185" to="c196" valeur="4"/>
<influence from="c256" to="c196" valeur="4"/>
<influence from="c544" to="c196" valeur="4"/>
<influence from="c437" to="c259" valeur="3"/>
</carte>
<carte type="attribuée">
<designer nom="YE02" couleur="#57c4fa">
<metadata>
<entry key="metier 2" value="aucun"/>
<entry key="taille" value="8"/>
<entry key="metier 3" value="aucun"/>
<entry key="metier 1" value="palangrier"/>
<entry key="port" value="port joinville"/>
<entry key="navire" value="le menhir"/>
<entry key="periode" value="1970"/>
</metadata>
</designer>
<concept id="c285" x="468.0" y="78.0"/>
<concept id="c234" x="220.0" y="421.0"/>
<concept id="c160" x="690.0" y="240.0"/>
<concept id="c545" x="158.0" y="199.0"/>
<concept id="c518" x="118.0" y="92.0"/>
<concept id="c196" x="424.0" y="307.0"/>
<concept id="c35" x="354.0" y="545.0"/>
<concept id="c159" x="619.0" y="152.0"/>
<concept id="c272" x="372.0" y="420.0"/>
<concept id="c557" x="230.0" y="140.0"/>
<concept id="c429" x="40.0" y="400.0"/>
<concept id="c503" x="639.0" y="526.0"/>
<concept id="c585" x="233.0" y="283.0"/>
<concept id="c632" x="690.0" y="50.0"/>
<concept id="c215" x="561.0" y="327.0"/>
<concept id="c77" x="563.0" y="33.0"/>
<influence from="c160" to="c215" valeur="4"/>
<influence from="c215" to="c159" valeur="4"/>
<influence from="c234" to="c196" valeur="-3"/>
<influence from="c632" to="c159" valeur="2"/>
<influence from="c35" to="c215" valeur="3"/>
<influence from="c159" to="c196" valeur="3"/>
<influence from="c585" to="c196" valeur="3"/>
<influence from="c215" to="c196" valeur="3"/>
<influence from="c285" to="c196" valeur="2"/>
<influence from="c272" to="c196" valeur="2"/>
<influence from="c35" to="c503" valeur="4"/>
<influence from="c429" to="c234" valeur="-2"/>
<influence from="c518" to="c429" valeur="4"/>
<influence from="c429" to="c35" valeur="4"/>
<influence from="c585" to="c557" valeur="2"/>
<influence from="c77" to="c632" valeur="3"/>
<influence from="c518" to="c285" valeur="3"/>
<influence from="c429" to="c585" valeur="2"/>
<influence from="c518" to="c545" valeur="3"/>
<influence from="c585" to="c545" valeur="3"/>
</carte>
<carte type="attribuée">
<designer nom="YE04" couleur="#245a91">
<metadata>
<entry key="metier 2" value="thonier"/>
<entry key="taille" value="17"/>
<entry key="metier 3" value="aucun"/>
<entry key="metier 1" value="chalutier de fond"/>
<entry key="port" value="port joinville"/>
<entry key="navire" value="le thalassa"/>
<entry key="periode" value="1970"/>
</metadata>
</designer>
<concept id="c359" x="310.0" y="80.0"/>
<concept id="c576" x="490.0" y="110.0"/>
<concept id="c579" x="177.0" y="478.0"/>
<concept id="c36" x="160.0" y="160.0"/>
<concept id="c305" x="510.0" y="196.0"/>
<concept id="c246" x="60.0" y="64.0"/>
<concept id="c150" x="66.0" y="399.0"/>
<concept id="c137" x="445.0" y="351.0"/>
<concept id="c215" x="70.0" y="280.0"/>
<concept id="c196" x="370.0" y="201.0"/>
<concept id="c216" x="150.0" y="340.0"/>
<concept id="c276" x="535.0" y="295.0"/>
<influence from="c150" to="c215" valeur="4"/>
<influence from="c246" to="c215" valeur="3"/>
<influence from="c359" to="c196" valeur="3"/>
<influence from="c579" to="c196" valeur="3"/>
<influence from="c36" to="c196" valeur="3"/>
<influence from="c137" to="c196" valeur="2"/>
<influence from="c215" to="c196" valeur="2"/>
<influence from="c216" to="c196" valeur="1"/>
<influence from="c246" to="c36" valeur="3"/>
<influence from="c576" to="c305" valeur="4"/>
<influence from="c276" to="c305" valeur="4"/>
<influence from="c305" to="c196" valeur="4"/>
<influence from="c579" to="c150" valeur="4"/>
<influence from="c215" to="c216" valeur="4"/>
<influence from="c246" to="c359" valeur="4"/>
</carte>
<carte type="attribuée">
<designer nom="YE05" couleur="#853322">
<metadata>
<entry key="metier 2" value="aucun"/>
<entry key="taille" value="13"/>
<entry key="metier 3" value="aucun"/>
<entry key="metier 1" value="caseyeur"/>
<entry key="port" value="port joinville"/>
<entry key="navire" value="la revanche"/>
<entry key="periode" value="1970"/>
</metadata>
</designer>
<concept id="c172" x="687.0" y="85.0"/>
<concept id="c196" x="382.0" y="287.0"/>
<concept id="c282" x="540.0" y="190.0"/>
<concept id="c141" x="295.0" y="443.0"/>
<concept id="c231" x="177.0" y="356.0"/>
<concept id="c617" x="626.0" y="473.0"/>
<concept id="c576" x="144.0" y="182.0"/>
<concept id="c246" x="732.0" y="269.0"/>
<concept id="c86" x="398.0" y="108.0"/>
<concept id="c143" x="180.0" y="450.0"/>
<concept id="c185" x="529.0" y="63.0"/>
<concept id="c635" x="455.0" y="401.0"/>
<concept id="c215" x="557.0" y="268.0"/>
<concept id="c145" x="32.0" y="418.0"/>
<concept id="c577" x="77.0" y="97.0"/>
<concept id="c221" x="570.0" y="332.0"/>
<concept id="c615" x="233.0" y="552.0"/>
<influence from="c141" to="c231" valeur="3"/>
<influence from="c635" to="c196" valeur="-3"/>
<influence from="c615" to="c143" valeur="3"/>
<influence from="c143" to="c231" valeur="-3"/>
<influence from="c145" to="c231" valeur="-3"/>
<influence from="c172" to="c282" valeur="-3"/>
<influence from="c86" to="c196" valeur="2"/>
<influence from="c185" to="c282" valeur="-3"/>
<influence from="c282" to="c196" valeur="4"/>
<influence from="c231" to="c196" valeur="4"/>
<influence from="c576" to="c196" valeur="4"/>
<influence from="c246" to="c221" valeur="4"/>
<influence from="c215" to="c196" valeur="4"/>
<influence from="c221" to="c196" valeur="4"/>
<influence from="c577" to="c576" valeur="3"/>
<influence from="c615" to="c635" valeur="2"/>
<influence from="c617" to="c635" valeur="4"/>
</carte>
<carte type="attribuée">
<designer nom="LT01" couleur="#88a49c">
<metadata>
<entry key="metier 2" value="aucun"/>
<entry key="taille" value="16"/>
<entry key="metier 3" value="aucun"/>
<entry key="metier 1" value="chalutier pelagique en bœuf"/>
<entry key="port" value="la turballe"/>
<entry key="navire" value="le fugitif"/>
<entry key="periode" value="1970"/>
</metadata>
</designer>
<concept id="c204" x="450.0" y="150.0"/>
<concept id="c288" x="690.0" y="325.0"/>
<concept id="c431" x="180.0" y="330.0"/>
<concept id="c307" x="70.0" y="140.0"/>
<concept id="c516" x="130.0" y="240.0"/>
<concept id="c382" x="412.0" y="501.0"/>
<concept id="c231" x="601.0" y="127.0"/>
<concept id="c272" x="40.0" y="369.0"/>
<concept id="c202" x="291.0" y="48.0"/>
<concept id="c86" x="461.0" y="36.0"/>
<concept id="c503" x="50.0" y="60.0"/>
<concept id="c33" x="496.0" y="323.0"/>
<concept id="c370" x="300.0" y="360.0"/>
<concept id="c235" x="220.0" y="150.0"/>
<concept id="c256" x="439.0" y="239.0"/>
<concept id="c360" x="380.0" y="320.0"/>
<concept id="c496" x="40.0" y="250.0"/>
<concept id="c215" x="645.0" y="240.0"/>
<concept id="c97" x="657.0" y="43.0"/>
<influence from="c288" to="c215" valeur="4"/>
<influence from="c307" to="c503" valeur="-4"/>
<influence from="c516" to="c235" valeur="4"/>
<influence from="c202" to="c235" valeur="4"/>
<influence from="c215" to="c231" valeur="4"/>
<influence from="c516" to="c307" valeur="4"/>
<influence from="c86" to="c202" valeur="3"/>
<influence from="c33" to="c256" valeur="2"/>
<influence from="c431" to="c235" valeur="2"/>
<influence from="c204" to="c235" valeur="3"/>
<influence from="c382" to="c215" valeur="2"/>
<influence from="c272" to="c516" valeur="4"/>
<influence from="c33" to="c215" valeur="2"/>
<influence from="c235" to="c204"/>
<influence from="c370" to="c382" valeur="3"/>
<influence from="c231" to="c204" valeur="3"/>
<influence from="c256" to="c204" valeur="3"/>
<influence from="c97" to="c231" valeur="-4"/>
<influence from="c307" to="c496" valeur="4"/>
<influence from="c272" to="c496" valeur="4"/>
<influence from="c360" to="c33" valeur="2"/>
<influence from="c235" to="c370" valeur="4"/>
</carte>
<carte type="attribuée">
<designer nom="LT02" couleur="#b379c1">
<metadata>
<entry key="metier 2" value="aucun"/>
<entry key="taille" value="17"/>
<entry key="metier 3" value="aucun"/>
<entry key="metier 1" value="chalutier pelagique en bœuf"/>
<entry key="port" value="la turballe"/>
<entry key="navire" value="le viking i"/>
<entry key="periode" value="1970"/>
</metadata>
</designer>
<concept id="c537" x="541.0" y="350.0"/>
<concept id="c94" x="256.0" y="89.0"/>
<concept id="c238" x="321.0" y="513.0"/>
<concept id="c473" x="288.0" y="190.0"/>
<concept id="c190" x="440.0" y="290.0"/>
<concept id="c196" x="519.0" y="519.0"/>
<concept id="c542" x="26.0" y="310.0"/>
<concept id="c90" x="164.0" y="135.0"/>
<concept id="c543" x="450.0" y="360.0"/>
<concept id="c536" x="517.0" y="215.0"/>
<concept id="c272" x="217.0" y="431.0"/>
<concept id="c369" x="10.0" y="350.0"/>
<concept id="c212" x="552.0" y="79.0"/>
<concept id="c37" x="51.0" y="253.0"/>
<concept id="c371" x="20.0" y="390.0"/>
<concept id="c550" x="629.0" y="259.0"/>
<concept id="c582" x="24.0" y="140.0"/>
<concept id="c554" x="90.0" y="510.0"/>
<concept id="c242" x="150.0" y="340.0"/>
<influence from="c190" to="c537" valeur="3"/>
<influence from="c90" to="c37" valeur="4"/>
<influence from="c582" to="c37" valeur="4"/>
<influence from="c190" to="c543" valeur="2"/>
<influence from="c94" to="c473" valeur="3"/>
<influence from="c37" to="c473" valeur="3"/>
<influence from="c242" to="c272" valeur="3"/>
<influence from="c212" to="c550" valeur="3"/>
<influence from="c242" to="c190" valeur="4"/>
<influence from="c473" to="c242" valeur="3"/>
<influence from="c537" to="c196" valeur="3"/>
<influence from="c550" to="c196" valeur="3"/>
<influence from="c242" to="c196" valeur="2"/>
<influence from="c190" to="c536" valeur="4"/>
<influence from="c196" to="c238" valeur="4"/>
<influence from="c242" to="c542" valeur="3"/>
<influence from="c242" to="c371" valeur="3"/>
<influence from="c238" to="c554" valeur="3"/>
<influence from="c242" to="c369" valeur="-3"/>
<influence from="c242" to="c212" valeur="4"/>
</carte>
<carte type="attribuée">
<designer nom="LT03" couleur="#3c138c">
<metadata>
<entry key="metier 2" value="chalutier pelagique en boeuf"/>
<entry key="taille" value="16"/>
<entry key="metier 3" value="aucun"/>
<entry key="metier 1" value="chalutier de fond"/>
<entry key="port" value="la turballe"/>
<entry key="navire" value="la patronne des bretons"/>
<entry key="periode" value="1970"/>
</metadata>
</designer>
<concept id="c555" x="57.0" y="460.0"/>
<concept id="c255" x="612.0" y="340.0"/>
<concept id="c167" x="440.0" y="120.0"/>
<concept id="c5" x="580.0" y="402.0"/>
<concept id="c196" x="520.0" y="300.0"/>
<concept id="c233" x="410.0" y="170.0"/>
<concept id="c490" x="350.0" y="150.0"/>
<concept id="c252" x="180.0" y="390.0"/>
<concept id="c231" x="0.0" y="140.0"/>
<concept id="c478" x="50.0" y="546.0"/>
<concept id="c512" x="190.0" y="150.0"/>
<concept id="c619" x="632.0" y="510.0"/>
<concept id="c134" x="49.0" y="235.0"/>
<concept id="c33" x="241.0" y="592.0"/>
<concept id="c23" x="440.0" y="440.0"/>
<concept id="c256" x="280.0" y="500.0"/>
<concept id="c539" x="632.0" y="276.0"/>
<concept id="c521" x="44.0" y="360.0"/>
<concept id="c360" x="491.0" y="532.0"/>
<concept id="c496" x="214.0" y="489.0"/>
<concept id="c215" x="639.0" y="40.0"/>
<concept id="c216" x="110.0" y="50.0"/>
<influence from="c134" to="c231" valeur="2"/>
<influence from="c216" to="c231" valeur="2"/>
<influence from="c215" to="c231" valeur="3"/>
<influence from="c167" to="c215" valeur="2"/>
<influence from="c196" to="c215" valeur="3"/>
<influence from="c490" to="c512" valeur="1"/>
<influence from="c512" to="c231" valeur="1"/>
<influence from="c478" to="c555" valeur="1"/>
<influence from="c360" to="c5" valeur="-2"/>
<influence from="c512" to="c490"/>
<influence from="c33" to="c256" valeur="3"/>
<influence from="c555" to="c521" valeur="1"/>
<influence from="c360" to="c256" valeur="2"/>
<influence from="c233" to="c196" valeur="-3"/>
<influence from="c555" to="c496" valeur="-1"/>
<influence from="c196" to="c539" valeur="2"/>
<influence from="c233" to="c167" valeur="1"/>
<influence from="c490" to="c167" valeur="1"/>
<influence from="c196" to="c496" valeur="2"/>
<influence from="c490" to="c196" valeur="3"/>
<influence from="c231" to="c196" valeur="3"/>
<influence from="c33" to="c496" valeur="2"/>
<influence from="c255" to="c196" valeur="2"/>
<influence from="c167" to="c196" valeur="2"/>
<influence from="c5" to="c619" valeur="-4"/>
<influence from="c252" to="c196" valeur="2"/>
<influence from="c521" to="c196" valeur="2"/>
<influence from="c256" to="c196" valeur="2"/>
<influence from="c5" to="c196" valeur="1"/>
<influence from="c23" to="c196" valeur="1"/>
<influence from="c360" to="c23" valeur="1"/>
<influence from="c215" to="c216" valeur="4"/>
</carte>
<carte type="attribuée">
<designer nom="NO01" couleur="#e39c8b">
<metadata>
<entry key="metier 2" value="palangrier"/>
<entry key="taille" value="10"/>
<entry key="metier 3" value="aucun"/>
<entry key="metier 1" value="caseyeur"/>
<entry key="port" value="noirmoutier"/>
<entry key="navire" value="le rene andre"/>
<entry key="periode" value="1970"/>
</metadata>
</designer>
<concept id="c497" x="350.0" y="542.0"/>
<concept id="c146" x="339.0" y="470.0"/>
<concept id="c207" x="687.0" y="470.0"/>
<concept id="c196" x="277.0" y="322.0"/>
<concept id="c259" x="429.0" y="274.0"/>
<concept id="c35" x="526.0" y="501.0"/>
<concept id="c621" x="11.0" y="253.0"/>
<concept id="c231" x="297.0" y="403.0"/>
<concept id="c272" x="242.0" y="264.0"/>
<concept id="c449" x="690.0" y="320.0"/>
<concept id="c606" x="250.0" y="195.0"/>
<concept id="c360" x="102.0" y="341.0"/>
<concept id="c215" x="490.0" y="350.0"/>
<concept id="c276" x="107.0" y="459.0"/>
<concept id="c102" x="222.0" y="139.0"/>
<influence from="c621" to="c360" valeur="3"/>
<influence from="c102" to="c606" valeur="2"/>
<influence from="c146" to="c231" valeur="4"/>
<influence from="c215" to="c231" valeur="4"/>
<influence from="c35" to="c497" valeur="3"/>
<influence from="c272" to="c196" valeur="-2"/>
<influence from="c35" to="c215" valeur="3"/>
<influence from="c449" to="c215" valeur="3"/>
<influence from="c606" to="c272" valeur="2"/>
<influence from="c360" to="c272" valeur="1"/>
<influence from="c259" to="c196" valeur="3"/>
<influence from="c231" to="c196" valeur="3"/>
<influence from="c276" to="c196" valeur="2"/>
<influence from="c449" to="c35" valeur="4"/>
<influence from="c35" to="c207" valeur="1"/>
<influence from="c449" to="c207" valeur="1"/>
<influence from="c449" to="c259" valeur="2"/>
</carte>
<carte type="attribuée">
<designer nom="NO02" couleur="#43a519">
<metadata>
<entry key="metier 2" value="aucun"/>
<entry key="taille" value="13,85"/>
<entry key="metier 3" value="aucun"/>
<entry key="metier 1" value="caseyeur"/>
<entry key="port" value="noirmoutier"/>
<entry key="navire" value="la danseuse de l'ocean"/>
<entry key="periode" value="1970"/>
</metadata>
</designer>
<concept id="c131" x="278.0" y="388.0"/>
<concept id="c168" x="523.0" y="312.0"/>
<concept id="c246" x="625.0" y="413.0"/>
<concept id="c278" x="352.0" y="463.0"/>
<concept id="c567" x="151.0" y="204.0"/>
<concept id="c569" x="410.0" y="64.0"/>
<concept id="c132" x="30.0" y="290.0"/>
<concept id="c196" x="386.0" y="278.0"/>
<concept id="c322" x="50.0" y="410.0"/>
<concept id="c446" x="189.0" y="82.0"/>
<influence from="c567" to="c196" valeur="3"/>
<influence from="c567" to="c446" valeur="3"/>
<influence from="c569" to="c196" valeur="3"/>
<influence from="c569" to="c446" valeur="3"/>
<influence from="c132" to="c196" valeur="3"/>
<influence from="c168" to="c196" valeur="4"/>
<influence from="c131" to="c278" valeur="3"/>
<influence from="c246" to="c168" valeur="4"/>
<influence from="c132" to="c131" valeur="3"/>
<influence from="c132" to="c322" valeur="3"/>
</carte>
<carte type="attribuée">
<designer nom="NO03" couleur="#a90d8e">
<metadata>
<entry key="metier 2" value="palangrier"/>
<entry key="taille" value="7,2"/>
<entry key="metier 3" value="aucun"/>
<entry key="metier 1" value="caseyeur"/>
<entry key="port" value="noirmoutier"/>
<entry key="navire" value="le frere de la cote"/>
<entry key="periode" value="1970"/>
</metadata>
</designer>
<concept id="c497" x="26.0" y="327.0"/>
<concept id="c303" x="233.0" y="153.0"/>
<concept id="c372" x="230.0" y="70.0"/>
<concept id="c160" x="40.0" y="460.0"/>
<concept id="c379" x="49.0" y="251.0"/>
<concept id="c196" x="337.0" y="234.0"/>
<concept id="c35" x="140.0" y="310.0"/>
<concept id="c272" x="606.0" y="190.0"/>
<concept id="c585" x="140.0" y="200.0"/>
<concept id="c137" x="457.0" y="333.0"/>
<concept id="c215" x="180.0" y="420.0"/>
<concept id="c301" x="430.0" y="74.0"/>
<concept id="c216" x="334.0" y="472.0"/>
<concept id="c276" x="66.0" y="83.0"/>
<concept id="c311" x="513.0" y="248.0"/>
<influence from="c160" to="c215" valeur="4"/>
<influence from="c35" to="c215" valeur="4"/>
<influence from="c35" to="c497" valeur="4"/>
<influence from="c372" to="c301" valeur="4"/>
<influence from="c301" to="c196" valeur="3"/>
<influence from="c216" to="c196" valeur="3"/>
<influence from="c585" to="c196" valeur="2"/>
<influence from="c276" to="c303" valeur="2"/>
<influence from="c372" to="c303" valeur="4"/>
<influence from="c379" to="c35" valeur="4"/>
<influence from="c303" to="c196" valeur="4"/>
<influence from="c272" to="c311" valeur="3"/>
<influence from="c137" to="c196" valeur="4"/>
<influence from="c215" to="c196" valeur="4"/>
<influence from="c311" to="c196" valeur="4"/>
<influence from="c379" to="c585" valeur="4"/>
<influence from="c215" to="c216" valeur="4"/>
</carte>
<carte type="attribuée">
<designer nom="NO04" couleur="#7cf270">
<metadata>
<entry key="metier 2" value="fileyeur"/>
<entry key="taille" value="13,75"/>
<entry key="metier 3" value="aucun"/>
<entry key="metier 1" value="caseyeur"/>
<entry key="port" value="noirmoutier"/>
<entry key="navire" value="le frere de misere"/>
<entry key="periode" value="1970"/>
</metadata>
</designer>
<concept id="c621" x="20.0" y="400.0"/>
<concept id="c171" x="134.0" y="145.0"/>
<concept id="c146" x="620.0" y="141.0"/>
<concept id="c180" x="340.0" y="220.0"/>
<concept id="c298" x="67.0" y="542.0"/>
<concept id="c601" x="356.0" y="494.0"/>
<concept id="c635" x="142.0" y="333.0"/>
<concept id="c237" x="600.0" y="400.0"/>
<concept id="c145" x="649.0" y="283.0"/>
<concept id="c196" x="380.0" y="330.0"/>
<concept id="c308" x="473.0" y="435.0"/>
<concept id="c311" x="180.0" y="472.0"/>
<influence from="c635" to="c196" valeur="-3"/>
<influence from="c145" to="c196" valeur="-3"/>
<influence from="c180" to="c196" valeur="3"/>
<influence from="c601" to="c311" valeur="4"/>
<influence from="c308" to="c196" valeur="3"/>
<influence from="c237" to="c196" valeur="1"/>
<influence from="c621" to="c311" valeur="2"/>
<influence from="c298" to="c311" valeur="2"/>
<influence from="c145" to="c146" valeur="3"/>
<influence from="c171" to="c180" valeur="2"/>
<influence from="c601" to="c308" valeur="4"/>
<influence from="c146" to="c180" valeur="4"/>
<influence from="c621" to="c635" valeur="4"/>
</carte>
<carte type="attribuée">
<designer nom="SN01" couleur="#19314b">
<metadata>
<entry key="metier 2" value="fileyeur"/>
<entry key="taille" value="8,6"/>
<entry key="metier 3" value="civelier"/>
<entry key="metier 1" value="caseyeur"/>
<entry key="port" value="saint nazaire"/>
<entry key="navire" value="le jepat"/>
<entry key="periode" value="1970"/>
</metadata>
</designer>
<concept id="c182" x="249.0" y="490.0"/>
<concept id="c497" x="693.0" y="124.0"/>
<concept id="c300" x="63.0" y="192.0"/>
<concept id="c303" x="214.0" y="226.0"/>
<concept id="c170" x="590.0" y="512.0"/>
<concept id="c372" x="257.0" y="122.0"/>
<concept id="c534" x="706.0" y="316.0"/>
<concept id="c167" x="388.0" y="440.0"/>
<concept id="c196" x="377.0" y="224.0"/>
<concept id="c35" x="554.0" y="86.0"/>
<concept id="c525" x="650.0" y="430.0"/>
<concept id="c274" x="240.0" y="330.0"/>
<concept id="c621" x="54.0" y="412.0"/>
<concept id="c110" x="654.0" y="241.0"/>
<concept id="c246" x="645.0" y="375.0"/>
<concept id="c302" x="62.0" y="139.0"/>
<concept id="c137" x="510.0" y="234.0"/>
<concept id="c635" x="160.0" y="270.0"/>
<concept id="c215" x="463.0" y="146.0"/>
<concept id="c221" x="443.0" y="327.0"/>
<influence from="c35" to="c215" valeur="4"/>
<influence from="c35" to="c497" valeur="4"/>
<influence from="c167" to="c170" valeur="-3"/>
<influence from="c246" to="c534" valeur="4"/>
<influence from="c525" to="c167" valeur="3"/>
<influence from="c372" to="c300" valeur="4"/>
<influence from="c635" to="c196" valeur="3"/>
<influence from="c137" to="c196" valeur="2"/>
<influence from="c372" to="c302" valeur="4"/>
<influence from="c372" to="c303" valeur="4"/>
<influence from="c110" to="c137" valeur="3"/>
<influence from="c182" to="c221" valeur="4"/>
<influence from="c372" to="c196" valeur="4"/>
<influence from="c167" to="c221" valeur="4"/>
<influence from="c274" to="c196" valeur="4"/>
<influence from="c215" to="c196" valeur="4"/>
<influence from="c221" to="c196" valeur="4"/>
<influence from="c525" to="c246" valeur="3"/>
<influence from="c621" to="c635" valeur="4"/>
</carte>
<carte type="attribuée">
<designer nom="NA01" couleur="#e67148">
<metadata>
<entry key="metier 2" value="civelier"/>
<entry key="taille" value="9"/>
<entry key="metier 3" value="aucun"/>
<entry key="metier 1" value="chalutier de fond"/>
<entry key="port" value="nantes"/>
<entry key="navire" value="le rock and roll ii"/>
<entry key="periode" value="1970"/>
</metadata>
</designer>
<concept id="c231" x="290.0" y="160.0"/>
<concept id="c142" x="195.0" y="223.0"/>
<concept id="c212" x="182.0" y="274.0"/>
<concept id="c153" x="30.0" y="90.0"/>
<concept id="c214" x="180.0" y="97.0"/>
<concept id="c215" x="167.0" y="161.0"/>
<concept id="c196" x="352.0" y="223.0"/>
<concept id="c432" x="30.0" y="270.0"/>
<concept id="c35" x="30.0" y="143.0"/>
<concept id="c523" x="20.0" y="210.0"/>
<influence from="c142" to="c215" valeur="4"/>
<influence from="c214" to="c215" valeur="4"/>
<influence from="c35" to="c215" valeur="4"/>
<influence from="c215" to="c231" valeur="4"/>
<influence from="c212" to="c142" valeur="4"/>
<influence from="c523" to="c142" valeur="4"/>
<influence from="c153" to="c214" valeur="4"/>
<influence from="c231" to="c196" valeur="4"/>
<influence from="c142" to="c196" valeur="4"/>
<influence from="c432" to="c212" valeur="4"/>
</carte>
</cartes>
</cogxml2>"""

output_directory = "data/icmap/kifanlo"
cmap_output = convert_xml_to_cmap(xml_input, output_directory)
print(cmap_output)
