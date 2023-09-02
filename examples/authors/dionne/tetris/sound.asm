	.module	sound

dorndm	ldd	$09
	andb	#$07
	addb	#$05
	bra	_dosnd
douhoh	ldab	#$04
	bra	_dosnd
donice	ldab	#$03
	bra	_dosnd
dotaunt	ldab	#$02
	bra	_dosnd
doslide	ldab	#$01
	bra	_dosnd
dohasta	clrb
_dosnd	ldx	#_sounds
	lslb
	abx
	ldd	,x
	std	SOUND
	ldd	$2,x
	std	SOUNDE
	ldaa	LVLCNT
	eora	#$01
	anda	#$01
	ldab	#$40
	mul
	orab	#$24
	stab	SBYTE		;clear sound byte
	ldaa	#$7E		;load 'jmp' instruction opcode
	staa	$4206		;store into TOF vector
	ldx	#_ocfi		;load interrupt location
	stx	$4207		;store as address to jump to
	cli			;enable interrupts
	ldaa	#$08		;enable TOF
	staa	08
	rts			;go back to BASIC...

_ocfi	ldx	SOUND		;increment sound pointer
	inx			;
	stx	SOUND		;
	cpx	SOUNDE		;see if at end of sound segment
	bhs	_done
	ldaa	SBYTE		;get the sound byte
	eora	#$80		;flip the sound bit
	staa	SBYTE		;store for safekeeping
	staa	$BFFF		;store into speaker/video select
	ldaa	,x		;get amount to sleep by
	ldab	#$50		;multiply by delay value
	mul			; (11.125kHz sample rate = 0.89MHz / 80)
	addd	$09
	bita 	$08		;read the TCSR
	std	$0B		;store into output compare register
	rti
_done	clr	0008		;disable the interrupt
	rti			;return from interrupt (back to BASIC)


_sounds	.word _hasta, _slide, _illbet, _nicetry, _uhoh
	.word _pbpbpt, _ddwner, _nngg, _ayaih, _psych
	.word _meow, _moo, _quack, _nomore

_hasta	.hex 022703330E05080103840C03124D053D; F
	.hex 10270419030205070205064604201307; 1F
	.hex 0248033C010B0C3107A4056A07031A7F; 2F
	.hex 1F4D020903A6050206ED023702280170; 3F
	.hex 08710C15084B14380E3F12600A060A38; 4F
	.hex 02340916031B030D0319030709040A03; 5F
	.hex 04020608020E030C04190116020B0706; 6F
	.hex 040D040A06060716040E0207050C0604; 7F
	.hex 0B06031D040C0505070B040C03070709; 8F
	.hex 0210050C0605060C030C041701090205; 9F
	.hex 06060A06060C030D0315050E06070A06; AF
	.hex 050C040C04060917050B0606050D030C; BF
	.hex 05090618040C050605020407030D0502; CF
	.hex 02050617040C06060204041D030C0315; DF
	.hex 050C07020505032C0218040E042A0827; EF
	.hex 050D0D520135022402CB0806029F15FF; FF
	.hex 9E1102FF0D0516430503038B09C20947; 10F
	.hex 0EFF530B040501540B150F3409100C37; 11F
	.hex 0E44080F0B1401420D160210052D0D14; 12F
	.hex 070B082E0F380A1E0A450D1706510901; 13F
	.hex 062A113908170F4305660302061F022F; 14F
	.hex 031804190238060D060104110A100428; 15F
	.hex 050D0C0F053B0E0D0629020403070303; 16F
	.hex 0C14030E06410C12050E051D053C070F; 17F
	.hex 030205110C0C043F0E150659049C0347; 18F
	.hex 094A01160CFD06980239082E0A130717; 19F
	.hex 0A2E091207180F3B1318052C0A0E0C51; 1AF
	.hex 036D09350A4D0A120F2D0919041C031D; 1BF
	.hex 06711151061609650D7D03FF155001FF; 1CF
	.hex FFFF68FFFF8A0816021E08130735010D; 1DF
	.hex 0F1305410A0A0A2903140414010E0315; 1EF
	.hex 0112090C053E0710042801CE033C0749; 1FF
	.hex 040304A909620BB1033D0EFF820C03FF; 20F
	.hex AA4B040202C502FFFFFFFFFFFFFFFFFF; 21F
	.hex FFFFFFFFFFFF71040312030303130D0B; 22F
	.hex 030303110A100C0F010302190F0E0C0E; 23F
	.hex 01020410020402110A0F0B0C0B130211; 24F
	.hex 0F100502020B0302041402050205010B; 25F
	.hex 0303092A0420020303100A1003130925; 26F
	.hex 090C01010A2804120510060203100302; 27F
	.hex 03600106010501170116036903480830; 28F
	.hex 0217075F040201160460031A07590120; 29F
	.hex 045B021D055B033D04FFFFFFAB170320; 2AF
	.hex 043D0815031D0B7E097D0445023E0285; 2BF
	.hex 09830A6708870716086C0717098D09FF; 2CF
	.hex 96
_slide	.hex 01C6029901A602D5252D2A23372D322B; F
	.hex 342A33253A223E210703362207011F06; 1F
	.hex 121F05091A07141F030C323031312C15; 2F
	.hex 04120303050127110411030B0B012011; 3F
	.hex 040B040F0B031F0C0401040B040B0B02; 4F
	.hex 03020D02120B0403020C030C0B030B03; 5F
	.hex 140B04040107080B070303020D02180B; 6F
	.hex 050B040C0402040405020405190B060B; 7F
	.hex 040C04030206040205031B0B050C040C; 8F
	.hex 040B0B05190B060B040C04060C07190B; 9F
	.hex 060B050B05060B071A0A060B050C0506; AF
	.hex 0A06190C040C050B06080809160C040C; BF
	.hex 040C06080D04140C040C040C09050B04; CF
	.hex 140C040B050D0805230A050B070E0506; DF
	.hex 0B02120A050C080D040A1B0A0502020B; EF
	.hex 040C04091B0A0303030C02120B021309; FF
	.hex 090B030F040A1501030A051F1A0A0103; 10F
	.hex 090A03100A020C0D09260D0E08140203; 11F
	.hex 1A0D09151A0E07121C0C071B120B0B16; 12F
	.hex 120E081213140410141B202219261227; 13F
	.hex 141B1F1F1C1C2019221B271B0D0C0B19; 14F
	.hex 0A0E0203102F17200204020409200303; 15F
	.hex 03020A04021D03020B02040303050119; 16F
	.hex 020311020305011E1628172004010404; 17F
	.hex 022511020326152A0C010326011C031E; 18F
	.hex 0414021E0320010B0204023902180203; 19F
	.hex 082D0B0F042106040B200303010C0501; 1AF
	.hex 051D0504020F09180105073302030B33; 1BF
	.hex 036902040333030402310C4401C1017D; 1CF
	.hex 01E803DC034C242C241B05172A140D1E; 1DF
	.hex 30140C1414030C100C120F120A101301; 1EF
	.hex 111207140C0D120C10120714070E110C; 1FF
	.hex 160F0A1303110803070311070A0A090C; 20F
	.hex 040F0703050408040D100A0A080A070B; 21F
	.hex 060B19130D090909070B060B0704080C; 22F
	.hex 1A0A080A070A060A0802090C0A050B09; 23F
	.hex 080A070A050B0A030203050B06040B09; 24F
	.hex 0809070A060C0B070805150809090709; 25F
	.hex 070D0C061D080909070A061109051A08; 26F
	.hex 0908080904100A05190709090709060B; 27F
	.hex 07061C070A08070A0414070313080908; 28F
	.hex 0809060B0604040410070A07080A0503; 29F
	.hex 04050C060F060A070909040405060B04; 2AF
	.hex 0F060A08060A0406040A190709080709; 2BF
	.hex 040F1D060A07040C0406050503021806; 2CF
	.hex 0A07060B04070404070113060908070A; 2DF
	.hex 01121D060A07050B010B04050A040D06; 2EF
	.hex 0908040D01121F050A08030D01130A04; 2FF
	.hex 11060A070807030B0405090312070808; 30F
	.hex 0609040A0405080314070808060A0206; 31F
	.hex 0304010522080709070C010503080C03; 32F
	.hex 160808090808090709040C020F0A0708; 33F
	.hex 070805080807060713090807080A080A; 34F
	.hex 07090B040C0909080807080604030206; 35F
	.hex 0A051407090A051E0A0609040F08080A; 36F
	.hex 050A070907050A06170D020C080B0609; 37F
	.hex 0707090508020A0B060B080907080709; 38F
	.hex 0606150D0909070A08090808220A090B; 39F
	.hex 070A070908070E060E0C080B070C080C; 3AF
	.hex 09080B030D0D080E060D070A09071D0F; 3BF
	.hex 0510050B070708072010080E050D0804; 3CF
	.hex 07080B050F10090D07130A091F13072B; 3DF
	.hex 1204190F072E2A150B1C0C030409130A; 3EF
	.hex 093B0D050B02030B10480B0E0B0A042C; 3FF
	.hex 06120A0F2715051112060F09113A080A; 40F
	.hex 0F0D0A0A03020F32050E1F0208090B02; 41F
	.hex 0215012B0A081909033B030304030B03; 42F
	.hex 150A093C0C01080B0103040402030217; 43F
	.hex 02220304010B0203030A03040216012B; 44F
	.hex 0609086E044D01020311037E030E044B; 45F
	.hex 0173030502240302032602AF010601F0; 46F
	.hex 01B501
_illbet	.hex 020D030702811108052505030C070907; F
	.hex 050D0406020505040601060605040207; 1F
	.hex 040E050D050404040D07090903100206; 2F
	.hex 040607050D080A09040D0506040D0704; 3F
	.hex 0A08090A022311030A0A05202B0D080D; 4F
	.hex 040D0A031A0B0711040C0B03140F0521; 5F
	.hex 213521382734283424381F3C0A050A42; 6F
	.hex 050B0705023A045C069C03FF1D03060E; 7F
	.hex 0A1C190F0913180D0C1009080E0C0C0F; 8F
	.hex 090A0E0C0C0E090C100B0C0F060C120E; 9F
	.hex 0A0F060D190B080E080E190E060C080D; AF
	.hex 0C010E0C0B0B070D0A020D0C0B0B090D; BF
	.hex 09010302090D0A0A0910140F080E0312; CF
	.hex 0F110911080B0D1109100C090C0E0615; DF
	.hex 090B0C0E091913380F3E13420D1E0301; EF
	.hex 031B0C4509240646074B024B0749059B; FF
	.hex 031701FF852719271414061215110B15; 10F
	.hex 16100B151A14031A1B311D2E0F0B0F1A; 11F
	.hex 0913072312380D090D28060B133B0D24; 12F
	.hex 03A6012E0315029804FF120407010781; 13F
	.hex 1B23192C1712021E150F071B160F061E; 14F
	.hex 1510061E1510061E1410071B180F061A; 15F
	.hex 1A11021B1B11021B1A2E1C2C192F1630; 16F
	.hex 16311B301F291D2A10380F39103A0C13; 17F
	.hex 061F0E180A180B11030404250C1E0216; 18F
	.hex 0D31131A1817051112130C0E10120D0F; 19F
	.hex 10110E1010110F1011100E1111100D13; 1AF
	.hex 12110D15132D152C160E032D14311113; 1BF
	.hex 0318140F09230E0A02020526100A0201; 1CF
	.hex 0524120B0921130D0822160B06220303; 1DF
	.hex 150C031F020303021B34192F15020E3A; 1EF
	.hex 0205140A03030232130905010305031F; 1FF
	.hex 2C31190804351508042F1A08042F0202; 20F
	.hex 1409043214090A301009050A042A0E09; 21F
	.hex 0609052D0E090509042F10040302050A; 22F
	.hex 0328010610040302050A030C011B0304; 23F
	.hex 11050103050B03270304130A040B031A; 24F
	.hex 020502040403130A050D0102030F030B; 25F
	.hex 0905140D06260A070F020A3604240A0E; 26F
	.hex 090E0A0F021008060D0D090B0910040D; 27F
	.hex 0A0A0B0C0A0B090D060B0A09100C060E; 28F
	.hex 080D080B0A07140E0A09070D070A0A1A; 29F
	.hex 060D0A20050F040C120E091E080C0605; 2AF
	.hex 031F0825041E0290051D014103020123; 2BF
	.hex 02FF6BCF061E061404FFC9291B0E0721; 2CF
	.hex 1C0C081001111B0D090D040F0A050F0C; 2DF
	.hex 090C080D08060F0C0A10020E050A0F0B; 2EF
	.hex 0A0C060E050C0F0B0B0C0311040B100B; 2FF
	.hex 0B0C0410040C110B0A0C071E100B0A0D; 30F
	.hex 061D100B0B0C071203080F0C0A0B071B; 31F
	.hex 100C0B0D0615140C0C0E0413120C0D22; 32F
	.hex 110F0C0E060D0D0F0B100B070F10090F; 33F
	.hex 1E0F0812190E091A0F0D0B1112100B10; 34F
	.hex 11110B0E10140B0216261013110B0617; 35F
	.hex 17210F010E1C090907180C340C280913; 36F
	.hex 063B04320329053A092F056E051D072C; 37F
	.hex 101204140E100B1011100C1013110C19; 38F
	.hex 14100D150A020F0F0B2016100B190A09; 39F
	.hex 100F0B2118120D160216141109250105; 3AF
	.hex 1A13010305162D180218110D0F390B02; 3BF
	.hex 0312021902200C3708120A1F021A0962; 3CF
	.hex 0780041E035807C402FFFFFFFAB81916; 3DF
	.hex 05181E13071B09041512071E020E1412; 3EF
	.hex 062F1A3729372C350D0F161203441221; 3FF
	.hex 0322080E1138040F08051338090F1A14; 40F
	.hex 081F0D210415042105270C1105420808; 41F
	.hex 051103210530084D13570B1507391F14; 42F
	.hex 033910130612033B0814054B0B110D40; 43F
	.hex 100E11480C041A480A031B5111040E49; 44F
	.hex 0608010912460C12040805440717020C; 45F
	.hex 0657070C0A540C0B05581B56145B1051; 46F
	.hex 0D
_nicetry
	.hex 20212E2D232D242D232D232D22282623; F
	.hex 2A212C222A2429252925282629220203; 1F
	.hex 26130B111B0202120B101E110F0D2111; 2F
	.hex 0B110B0314110B0C0304020B1510060B; 3F
	.hex 0304020D0401150C0301060B04130402; 4F
	.hex 140C0A0B05140205130B0B060A0D0305; 5F
	.hex 0106120C0B05090E050B130B0B070412; 6F
	.hex 040A150A090A0314030C160A070C040E; 7F
	.hex 0212140B060C061C1B0B050C051E1A0A; 8F
	.hex 070C0315030B170A060C0422170A060C; 9F
	.hex 0522150B060C031E0605110B05110324; AF
	.hex 120A0601020D04241209090D0812030B; BF
	.hex 100A091202150309120A061402160703; CF
	.hex 110A082C180C0928170D0C25160B1123; DF
	.hex 140E0D2312120E1F1210131606010F14; EF
	.hex 101613191210171A1112171513160F0E; FF
	.hex 0407092402090111173D163A02021319; 10F
	.hex 0421020F04110A250116020206010D1B; 11F
	.hex 0301041A1021081B0D280219091C012D; 12F
	.hex 0A18020304490A4A0103050102FFFFFF; 13F
	.hex FFFF1504022501050205023C03040211; 14F
	.hex 0112030E010402040209010A02040304; 15F
	.hex 03060204020403040205010502040205; 16F
	.hex 0204020A020602050204020402050306; 17F
	.hex 03030304030302030204030702040304; 18F
	.hex 03040305030502090105020901050205; 19F
	.hex 03050304030503060205010303040205; 1AF
	.hex 03040403030404040305030402040304; 1BF
	.hex 0304030502090106020E020502040105; 1CF
	.hex 0209010503040305030602050204010F; 1DF
	.hex 02050106030503060205040503060206; 1EF
	.hex 04060216021002100206011101060305; 1FF
	.hex 04050305030504060305030702050308; 20F
	.hex 0205040404040406030602180303201A; 21F
	.hex 0E071702011B030E1C2E190301140216; 22F
	.hex 1A170415191704111E16031120150312; 23F
	.hex 210E09111001120E07121102120E060E; 24F
	.hex 0E04190E050E0D07180E050D0A0A180E; 25F
	.hex 060D070C190E050D070C180E060C060C; 26F
	.hex 180D070C060C160E060D050A170D051F; 27F
	.hex 14070412040F13070B0B060F10070B1D; 28F
	.hex 0E080C09090B0C0A0B08090A0D0B0809; 29F
	.hex 0A080E09080B0A090C08090B030B0E09; 2AF
	.hex 0A0909080C070B0907090D080A090909; 2BF
	.hex 0D08090908090E080A0909090F070A08; 2CF
	.hex 080A04040B070A080A0D0F070A070B0E; 2DF
	.hex 0E080A07090F060608080907071C0A07; 2EF
	.hex 0A08070F08060C070A070907050A0407; 2FF
	.hex 0B070A060A1C08040A070A08080C0607; 30F
	.hex 07080D0709070A0D020801080A040B07; 31F
	.hex 0A070908080F020C12060A07090E030D; 32F
	.hex 030504031309070A060B050A070A0D03; 33F
	.hex 0D0A050B0614050A0704130B060A050C; 34F
	.hex 0908080A160B060A07090808070B0506; 35F
	.hex 0E0B050B060B070D030C06030F0B050B; 36F
	.hex 090C050B0303030B130A050F060B080A; 37F
	.hex 080B120B0402030B080B080B0A06110A; 38F
	.hex 090C090A090D0B060B0E080C080C070F; 39F
	.hex 14100810070B080F101001020515090C; 3AF
	.hex 1F0E0A140E09120102110D150C091214; 3BF
	.hex 091812031316010206171D3B1B352337; 3CF
	.hex 1B490B020F3E1A4014310B0905030931; 3DF
	.hex 020203030A49065107FFFFFFFFFFFFFF; 3EF
	.hex FFFFFFFFFFFFFFFFFFFFFF74030A1211; 3FF
	.hex 0C0C1319120F0510120D030206020405; 40F
	.hex 020418120A0C12010702030C0B111C0B; 41F
	.hex 0B0E090A0D0E0B0C090B0F0C0B0B0A0C; 42F
	.hex 13100A1A1C0B0A10040911040E0F060C; 43F
	.hex 090A0D070A10090C050202050B19100B; 44F
	.hex 0B0C050D0A0C1105032B080B120D0313; 45F
	.hex 040D101F0B0704030405020503030503; 46F
	.hex 020E0202050B0D0A0702020C0603010C; 47F
	.hex 040C03010504040106070903020C0503; 48F
	.hex 02050B1104040204190402050402050B; 49F
	.hex 0A0C0603020405010F0401060B0B070F; 4AF
	.hex 06040204140B0B0B0B0602030A0C180B; 4BF
	.hex 0A0C040D0B02100B0B0C060B02040504; 4CF
	.hex 03040F0B0B0C040E0A040E0C0B0C060C; 4DF
	.hex 0B04100C0B0D030402080B0401040D0B; 4EF
	.hex 0B1F04030E0D0C0C0512140D0D0B060E; 4FF
	.hex 170E0C0D0514100F0D0C040E17100F13; 50F
	.hex 050316170E120E020E150D1307021513; 51F
	.hex 110F09041118091F15150A1F161C0715; 52F
	.hex 1E0F0D1B1911101814120F1B12111016; 53F
	.hex 030111100D0D01120E0E090E090D0F0D; 54F
	.hex 090D0A0A140D080D090B170C080C090B; 55F
	.hex 170C080B080C08020E0C070B080C0709; 56F
	.hex 090B080B080B07020304090B080B080B; 57F
	.hex 07090A0A080B080B0908090B070B090A; 58F
	.hex 0A06090B080A0A090B05080B0A09090B; 59F
	.hex 150202080A0B060D1104030504040421; 5AF
	.hex 0D0D02010602051E0E160820160B0726; 5BF
	.hex 0E0B0B130C1104070D12050308100208; 5CF
	.hex 0A150E0A090A09170A0B0C06061C080B; 5DF
	.hex 070B0A1A090B070B081C070C070C071C; 5EF
	.hex 080C060C070E04090B1C0A040E1E1B28; 5FF
	.hex 1726192913150612131309111118060F; 60F
	.hex 1114090F131308121118060F12170310; 61F
	.hex 13281012031710100417100F05030112; 62F
	.hex 100F05160F0C010204170F0A09110104; 63F
	.hex 0E0B091003030D0B091101050C0C080C; 64F
	.hex 010A0C0C070C03090C0B060D04080C0C; 65F
	.hex 040E03090D0B030F030A0D0502030310; 66F
	.hex 020A0D040810030B070302040810020B; 67F
	.hex 0709091C0709091B070A080A07090809; 68F
	.hex 080C09050809080D0902090B070D1207; 69F
	.hex 0B0D10080A100A02010A0A0F0D0E0B10; 6AF
	.hex 1114030C050A010309290D0B06180B0D; 6BF
	.hex 05170506060C070B050C080A020A0A0F; 6CF
	.hex 050C04090A1D08090A1A0709080C0212; 6DF
	.hex 040502030812010D010206030412070A; 6EF
	.hex 0B17060B091B051D090D071A090D0320; 6FF
	.hex 0401031B0411040C0230072C062E0217; 70F
	.hex 011C021F061703040214061501010603; 71F
	.hex 0210031E082D08FFFFFFD80503140204; 72F
	.hex 01310311041401140105020D02050126; 73F
	.hex 0219010602450204042503020E331821; 74F
	.hex 07021A2318201B210603120D020E0B04; 75F
	.hex 100D040D0B060E0C060B0A090C0D060C; 76F
	.hex 080B0C0C070B090A0C0C070C080B0C0C; 77F
	.hex 070C080B0D0B070C070C0E0C070C060C; 78F
	.hex 0F0D060C060C100D050D060B110D050D; 79F
	.hex 070A120D050D060B120D06020308030E; 7AF
	.hex 100D0A0B020E110B090D040D100C080E; 7BF
	.hex 040C120B080D050C120B080D040D120B; 7CF
	.hex 080E030D1309090F040D1209090E040F; 7DF
	.hex 110B080D041010090A0B061110080A0C; 7EF
	.hex 051112070A0C05180C070A0B06170D07; 7FF
	.hex 0A0A07180C0C060A06180D080A0B0518; 80F
	.hex 0D0B070C05160E0B070B06160F0B060B; 81F
	.hex 0715100B0607010207180E0C060D0417; 82F
	.hex 0F0B070C0418100A070D0316120B060C; 83F
	.hex 0512150B070C0410180B062007040E0B; 84F
	.hex 071E07060D0A0710030D04070D0B070E; 85F
	.hex 050D05050E0A080E040C07050D0A080E; 86F
	.hex 040D06050D0B090C041104030E0A090D; 87F
	.hex 041005020E0B090C0410150B090D0311; 88F
	.hex 150D070E0210160D0622150B0920150B; 89F
	.hex 0921140B0921130C0822130E0820120F; 8AF
	.hex 081E140F081C150E0A1C020313331631; 8BF
	.hex 1814011A192F192E192E172F13311331; 8CF
	.hex 1634161F0411131C0810111A02190F39; 8DF
	.hex 0E3D0B3E0C3407020A33173214350D3B; 8EF
	.hex 0C40064104
_uhoh	.hex 060D05030109030A070D050D0208130D; F
	.hex 050F0C050304050E0B060E090A0E0406; 1F
	.hex 11090A0908091309090B070B10080A08; 2F
	.hex 090815080A080A0712080B070A080F0B; 3F
	.hex 0A080A080E09090A080810080A090908; 4F
	.hex 0E080B080A080C090A090A090D090909; 5F
	.hex 0A0A0C090A080A0A0C090A080A0B0B0B; 6F
	.hex 08090A090704060C0909070909080809; 7F
	.hex 090A080A070C080B06080A0E04060A09; 8F
	.hex 0B08050C070C040A090E060D040D0917; 9F
	.hex 040F02090B0A0622080C060B050C0D0C; AF
	.hex 051F080203090206040702100A0C040C; BF
	.hex 060E0710040D060C0514050C070B080C; CF
	.hex 060D0A0B090D050E090E070B060C080A; DF
	.hex 05110512050B050E053A0337040F020E; EF
	.hex 070E06220313061F0810070F050B050F; FF
	.hex 031C060F0A07050E040F0B09090B070B; 10F
	.hex 0908090B070D060A090A080B080B0909; 11F
	.hex 0B0D0B09030F0C050B090A0B070A0907; 12F
	.hex 0E090A0B070B09080E090B0A080A090A; 13F
	.hex 0F080C0909090A090B0404070304060C; 14F
	.hex 060C070B0805060C080C060C080A0A02; 15F
	.hex 06070302070D060C070B0903070C070C; 16F
	.hex 070B080A0A03080C060C070A0A070C05; 17F
	.hex 070C070D060C07080D02080C070C060B; 18F
	.hex 09080D04080D060D060B09060E03090D; 19F
	.hex 060D060B08060E030A0C080B070A0A07; 1AF
	.hex 0C040A0B080C07090C041B0D080B070A; 1BF
	.hex 0A070D040A0C080C080A090A0C03070B; 1CF
	.hex 0A0A09090A070E06070B0A0A09090A08; 1DF
	.hex 0C08090B090B090D080A0A07070D080A; 1EF
	.hex 090C09090E030708030108090A0B0B08; 1FF
	.hex 19090C09090C0D07040310080D09090D; 20F
	.hex 0C0716090D0A090C0A09180A0B0A090D; 21F
	.hex 0A0916090C0A090D0B0B13090D0A080F; 22F
	.hex 0B0A100A0D0A0B0C0C08100A0D0A0C0A; 23F
	.hex 0D070F0B0C0C0C0A0E050B0C0B12090E; 24F
	.hex 170C0C14080F120C0D1E09070F0C0A0D; 25F
	.hex 04111C0B0610070E1E0A0910070C0A03; 26F
	.hex 130A0925203D1002123623371F3A1E0C; 27F
	.hex 0530050B0A0A0711050B0E050232030E; 28F
	.hex 190D041304131C110314040F0B02103B; 29F
	.hex 11070932100117120413010A080D0A42; 2AF
	.hex 0311044006120314027C044203041351; 2BF
	.hex 012304170610043D0217034C020A09E1; 2CF
_pbpbpt	.hex 0D01082513050B0E0402070206261406; 4F
	.hex 0A0F030206030725140C070F0A050425; 5F
	.hex 13060306071206050524150403070611; 6F
	.hex 0706070802181C070713050409211A0A; 7F
	.hex 061307020A211B09060F16231A0A060E; 8F
	.hex 1822190C050E1723190D050D1524190D; 9F
	.hex 050D0E2C180F040C0D2D180F050C0D2D; AF
	.hex 1A0D050B0D2D1B0D050B0D2E190F0506; BF
	.hex 112F180F06060D331612070405030211; CF
	.hex 0323151308030516022416130802043F; DF
	.hex 1513091D022517110A0E020E05211810; EF
	.hex 0B1C0501041E17130B1D072015130D11; FF
	.hex 20101817054711150F12161C1310140D; 10F
	.hex 1A1D12170401080F0B070223110A010A; 11F
	.hex 0601090A0C2E151B0622071C1F0B0103; 12F
	.hex 0B1D081E11190C14191713150F200203; 13F
	.hex 011E1314120C1F181020071E0A1D1415; 14F
	.hex 10060108191C1D13091E07211B110D10; 15F
	.hex 010B0A1F1B0F10190D1E12040317091D; 16F
	.hex 081403091C15081C0A201C1004010B1C; 17F
	.hex 0525191B09180D060805020B171D0911; 18F
	.hex 2304010B141F0A1C08211C11101C0524; 19F
	.hex 1D0E1414011D01111B190C44171A0D44; 1AF
	.hex 19190D441B15101D020F02121D091A1D; 1BF
	.hex 02231A0D191C04221201041A0B1F0122; 1CF
	.hex 1413141D0420170E150F030B071D101D; 1DF
	.hex 0C111C1410190F1D0A1A12160E21061C; 1EF
	.hex 180B120C0502181713130D16022D1312; 1FF
	.hex 0B0102180525111503010A490B180C15; 20F
	.hex 05180104032E0C150E1C0D1905020B14; 21F
	.hex 131009030E13180F136D076C0D180F43; 22F
	.hex 05200A07070C12011826086E081F0D13; 23F
_ddwner	.hex 052B0D260D280C290C290B2C0B2B0A2C; F
	.hex 0B2D0A2D0A2C0B2D0A0803210B070421; 1F
	.hex 0B0704210B0704220B0604220D070122; 2F
	.hex 0E070501031304090A231704041A040A; 3F
	.hex 0A2105090B0A070C050B0E2404050F0E; 4F
	.hex 031201090E0D030E0409120A050B0415; 5F
	.hex 0809050A0508030A090904240C090522; 6F
	.hex 0D0907210B070618010A0E0706150408; 7F
	.hex 0E09051503080F08061404070E090514; 8F
	.hex 050609020508061206070D0905120607; 9F
	.hex 0A020408051305080E070608010A0508; AF
	.hex 0D080508020905090D08061205090F07; BF
	.hex 0611050A0E08051304090E0805110609; CF
	.hex 0F070610020E0C070610060B0B080510; DF
	.hex 050D0A07051206070E06061306060C07; EF
	.hex 061502080C070512030A0C07061D0D08; FF
	.hex 061103090C07061205070C0806130407; 10F
	.hex 0B07061304070C08051E0B08061D0B08; 11F
	.hex 071C0B08061C0B08071A0B08091A0A08; 12F
	.hex 081A0A0A071B080B071D090A091D0909; 13F
	.hex 0401071F0B070811011406030C220922; 14F
	.hex 040B0C1E060D071B030905410720050A; 15F
	.hex 072006080820050B07200312032E0623; 16F
	.hex 020D043205310631052F0832056605FF; 17F
	.hex 8DD3083F053F093D0A3E0B0B02300B08; 18F
	.hex 05330B0704350C22021E0B20031F0A21; 19F
	.hex 04090314091F060902140A1E071F0B1E; 1AF
	.hex 071E0C1D081F0C1C08200C1A09200D2C; 1BF
	.hex 0211101E0813030A0B0D070B070F060A; 1CF
	.hex 0A0B080B080B070A0C0B0314061E0F09; 1DF
	.hex 070B080B050B08030809070A080C0315; 1EF
	.hex 0B09070A062203030B09060B04280B09; 1FF
	.hex 070A04270F08050B022704030B070621; 20F
	.hex 040C05050B0903390A09053C0B0A050B; 21F
	.hex 03290D08050B032E0C08050904220209; 22F
	.hex 0A0806090309030A0314070404070609; 23F
	.hex 0309030A031306030408060A0308010B; 24F
	.hex 0315060204080608042E0C0805090414; 25F
	.hex 02160603050706090308030B02140703; 26F
	.hex 04080509042B07030507060804090121; 27F
	.hex 06040507060804080320050505080509; 28F
	.hex 0308020B02150E070609030802230D07; 29F
	.hex 06080408030903140506060705080407; 2AF
	.hex 041F0606060606080407032005060607; 2BF
	.hex 060704070321050506070509032B0605; 2CF
	.hex 04080509032B040605070609032B0603; 2DF
	.hex 0408060A022B06030408060A04290704; 2EF
	.hex 02090509062A060F0509052809020309; 2FF
	.hex 060905270C0806090613040A0506080B; 30F
	.hex 050B05260D09070906220802080A060A; 31F
	.hex 060A03170812050A05260A09070A070B; 32F
	.hex 050B0706080B050C050D03100E0A070A; 33F
	.hex 080B060B0708080B060C060C050C0908; 34F
	.hex 050E050B060B060B090E060F060D050D; 35F
	.hex 0912040E04230A0F050E07210B0D070D; 36F
	.hex 0710050C0B0C080C080F040E0B0D070D; 37F
	.hex 072308260124070F050F031A020C070F; 38F
	.hex 042D040B034E05
_nngg	.hex 0E270A290C2810231124102513241225; F
	.hex 13241326122514261426162515241527; 1F
	.hex 15261623030B0C0F061D0C0E071C0D0D; 2F
	.hex 061E0E0C06200E0D03220E22030E0E20; 3F
	.hex 050E0E20040F0E0F031F0F0E041F1030; 4F
	.hex 10310F320F22010F0E21030E0F311031; 5F
	.hex 10310F20040D10310F320F3110310F31; 6F
	.hex 0F22010E1021020E0F320F320F320F23; 7F
	.hex 010E0E320F330E340D340E3410150218; 8F
	.hex 10310F320D320E320D2E112C122E102E; 9F
	.hex 10300F2603080D2F0F2907010E2B122F; AF
	.hex 0F33112E112F10310F2F10301130122F; BF
	.hex 123112311232103E093C0A3D0C3A0C0D; CF
	.hex 04280F0E012910371235123713381236; DF
	.hex 13351533163317331733173416340802; EF
	.hex 0E33173108070C3405070C2101110607; FF
	.hex 0101092201100608093306060C321634; 10F
	.hex 1535183016321231132F122D0F330C31; 11F
	.hex 0B2911291426132A102A0E1E16231523; 12F
	.hex 132612251222142211260F2711241126; 13F
	.hex 11241026122510291026112910271328; 14F
	.hex 13261626162A0F34044202320B320C2E; 15F
	.hex 0D2D0E2C0E2D0E2C0F1705110F140810; 16F
	.hex 0F1508100E130C100E130C100E120C11; 17F
	.hex 0E120B120F110B111011091311110813; 18F
	.hex 122A142915280A020A2902090A330B31; 19F
	.hex 0C2E0F2D101303161113031512120514; 1AF
	.hex 101406130F1605131014061310130713; 1BF
	.hex 10120813101209121012091211120813; 1CF
	.hex 1012081310120813101208130F130813; 1DF
	.hex 0F1308140E1407140F1303190E320A39; 1EF
	.hex 0230033904150B330D320D340984088C; 1FF
	.hex 0838088C07370D92013A030401330A37; 20F
	.hex 09840A350E1509150F14091510120B15; 21F
	.hex 10120B1510120B1511110C140F140B14; 22F
	.hex 0F150A14101707160A03031904180805; 23F
	.hex 031A0219040904030312031B010A0A3A; 24F
	.hex 0C13031F101304200E1503210E12061B; 25F
	.hex 1312071A121109191212091912120918; 26F
	.hex 1313051A1533030204050B2F07021039; 27F
	.hex 0F360E3514380F3415380F370F390F34; 28F
	.hex 02030F380F34030310361015041C1216; 29F
	.hex 031D1117011D12351239103510351234; 2AF
	.hex 1333123202041038122E192C192C1434; 2BF
	.hex 1731100302360E3F073C0B4003
_ayaih	.hex 03070406041304080406040401030405; F
	.hex 04060301030A02050306030304040406; 1F
	.hex 07050204030404060302040504050302; 2F
	.hex 02050303030503060303040404050303; 3F
	.hex 02050104030504040401040405040501; 4F
	.hex 0206020C020403020405040506060405; 5F
	.hex 03080303040405050605040504060503; 6F
	.hex 03050405050604050407040303050405; 7F
	.hex 05060405030605030404050504070404; 8F
	.hex 03070402040504050408030503050502; 9F
	.hex 04040405040802050505080504050408; AF
	.hex 03050405070504050305020503010304; BF
	.hex 03010405050504070404060304040506; CF
	.hex 03080304050304040506030704040504; DF
	.hex 04040406040703050403040405050406; EF
	.hex 04050303040404060407030504030304; FF
	.hex 05060308030508040506040704040805; 10F
	.hex 04060407030409040406050604040705; 11F
	.hex 04060407040308040506040703040705; 12F
	.hex 04060407030407050406040604040704; 13F
	.hex 05060307040406040506040604040604; 14F
	.hex 05050505040505040505040604040504; 15F
	.hex 05050406040405050405050505040404; 16F
	.hex 06040407030408050405040505050504; 17F
	.hex 04050404070504050506040406060405; 18F
	.hex 05070404050704040607040405070304; 19F
	.hex 06060405050604040606040406060504; 1AF
	.hex 05070404060604040607030406060504; 1BF
	.hex 05060405050704040606040406070403; 1CF
	.hex 06080403060704030608030406060404; 1DF
	.hex 06060404060804030608030307080303; 1EF
	.hex 06080501070905010607040306080404; 1FF
	.hex 05080403060803030707050207080403; 20F
	.hex 06070503050804030608040405080403; 21F
	.hex 06070403070704030707040306080403; 22F
	.hex 06080304060704040607040406070403; 23F
	.hex 06080404050804040607040307070403; 24F
	.hex 07070403060804040608030406080403; 25F
	.hex 07070503060804030708040207080404; 26F
	.hex 050904030509050207070503050A0503; 27F
	.hex 05080504040905030608040405090502; 28F
	.hex 05020206050304020206040404020206; 29F
	.hex 05040301030605040806040408060404; 2AF
	.hex 08070404080604050806040507060504; 2BF
	.hex 08060405040301060306090503060403; 2CF
	.hex 030D0401040604040907030504010406; 2DF
	.hex 03050501030604040502030604040402; 2EF
	.hex 03050504040303060504040203060404; 2FF
	.hex 04030306050304030306050304030306; 30F
	.hex 04050304020605040304030604050303; 31F
	.hex 04050405040303060504040303050504; 32F
	.hex 04040306050503040305050503040405; 33F
	.hex 04050404040504050403050504050404; 34F
	.hex 04060405040404050406030504050505; 35F
	.hex 05030405040505040505040504040505; 36F
	.hex 04050405050505050504040504060404; 37F
	.hex 05060405050505050405040506050405; 38F
	.hex 05040606030703050706040504050706; 39F
	.hex 04060306080503060405060603060404; 3AF
	.hex 04050405030604070503010603070209; 3BF
	.hex 0514020A061902030521040701060109; 3CF
	.hex 0310051D0418021B0304042201170326; 3DF
	.hex 030E0132040B01250311021101090316; 3EF
	.hex 014C020803060108024304
_psych	.hex 080C0B0A0C090D090D090A0D08050109; F
	.hex 0705040707030608060207080F090E09; 1F
	.hex 0602070A0D0A0C0C0A0E0812040B0306; 2F
	.hex 04090307040A0209030704090307030B; 3F
	.hex 0305040B0305020D030507080205080D; 4F
	.hex 0A08040208080501070A0C0905010609; 5F
	.hex 05020609050106090601050A0B0A0501; 6F
	.hex 06090C090502050A0501060905020509; 7F
	.hex 0502050A0403040A040305090503040A; 8F
	.hex 040305090502050A040305090502050A; 9F
	.hex 0403060806010608060107080D080D09; AF
	.hex 0D080E080D080E080D080E080D090D09; BF
	.hex 0D080D090D090D0B0B0D090D0A0C0B0B; CF
	.hex 0D0A0D0A0C0D0A0E090D0A0D0C0B0D0B; DF
	.hex 0C0D0B0D0A0E0A0E041102100A0D0B11; EF
	.hex 0612030B0111080F0A0C0B0E0811043C; FF
	.hex 030C0303050B0204050B0204050B0203; 10F
	.hex 0510050F070F07100611051105120313; 11F
	.hex 03350205021402140178011C0313041D; 12F
	.hex 09120A120B150B1309160A130A19073A; 13F
	.hex 06130425083F061F02160913071B0619; 14F
	.hex 051A0418031C02
_meow	.hex 0420071E061F041F061D0A1A081C091A; F
	.hex 091B071C081B081A0A1A091A091A0918; 1F
	.hex 091B081A09190819091808180A160919; 2F
	.hex 0A1608180A160A160918081709170917; 3F
	.hex 091709160A17091709160A160A150918; 4F
	.hex 07170A15081708170817081508170817; 5F
	.hex 0617081706170717081508130C140915; 6F
	.hex 091509130C130A140B130A150A130A14; 7F
	.hex 0B130B130B140B140A1409150A140A13; 8F
	.hex 0C130A130C130B100E130B130C0D110E; 9F
	.hex 0306080D0406080C0507060C0607060C; AF
	.hex 0608050B060A050B0608050A06090609; BF
	.hex 07090609080A050A070B0609050A0609; CF
	.hex 050B0709050B0709050B080B030A080A; DF
	.hex 030B0818081809170817090C020A080B; EF
	.hex 0408090C0309090C010A0A170A050110; FF
	.hex 0201071B0619090B0409080C02080B0D; 10F
	.hex 02080A0C030703020619080B04080103; 11F
	.hex 060B040B060C040B070B040B061A080C; 12F
	.hex 030B070C030A080C030803010619090C; 13F
	.hex 03080202060C030C070C03080A050204; 14F
	.hex 04080202060D030C05060204040C0510; 15F
	.hex 01090905020504070104050D040B060C; 16F
	.hex 040C060C04090806010504070104060C; 17F
	.hex 040B070B04070104060C040B06060205; 18F
	.hex 0307010406060106030C060502050406; 19F
	.hex 0105060C030701050605020503060204; 1AF
	.hex 060601060306010506050205040C050D; 1BF
	.hex 040B060D040B060C040B070C040B070C; 1CF
	.hex 040B060C050B060C040C060C040C060C; 1DF
	.hex 04060105060C040C060C040C06060105; 1EF
	.hex 040C060C040C06060105040C06070104; 1FF
	.hex 040B07070104040B07060204040C0606; 20F
	.hex 0204040C06060304030C06070204040B; 21F
	.hex 06060304030C07060204040B07060204; 22F
	.hex 040C06060204040B07060204040B0706; 23F
	.hex 0304030A08060304030B07060304030A; 24F
	.hex 08060304040908060404030909060304; 25F
	.hex 03090906030404080906040403090807; 26F
	.hex 030502090807040F0906040F09070310; 27F
	.hex 0807040F080803070207070804070107; 28F
	.hex 07080407020707070506020707080406; 29F
	.hex 03060807040702070708030801070807; 2AF
	.hex 04070207070705060306080704100708; 2BF
	.hex 04070108070704100708041007080310; 2CF
	.hex 080704100807040F0907040F08080310; 2DF
	.hex 0808030F09080310080803100809030E; 2EF
	.hex 0909040C0B08050C0A09040A0D080509; 2FF
	.hex 0D0905080E0805080701070805080E08; 30F
	.hex 06070F0806090C09050A0C0806090D08; 31F
	.hex 06090C0906090C0905090D0806090D08; 32F
	.hex 06090C0906080D0905090D09050A0B0A; 33F
	.hex 050A0B0A06090C0906090B0A060A0A0A; 34F
	.hex 06090C0906090C09060A0B0A050A0B0A; 35F
	.hex 050B0A0A060A0A0A060A0A0A060A0A0A; 36F
	.hex 060A090B060A090B0709090B0709090B; 37F
	.hex 060A090B0709090A0809090A0809080B; 38F
	.hex 0809080B0809090A0809090B0809080B; 39F
	.hex 0809080C0808080C0808090C0709080C; 3AF
	.hex 0809080B0809080C0709090B0809080B; 3BF
	.hex 0809080C0709090B0709090C0709090B; 3CF
	.hex 0709090C060A090C06090A0C0609090E; 3DF
	.hex 040A091C0829090B050C090C0311030A; 3EF
	.hex 061C071D071E071D081E071C081D061F; 3FF
	.hex 050C0310040F0210030E0210060C040E; 40F
	.hex 051F0520051F051E061F062004210320; 41F
	.hex 0421040E042102220321062102220322; 42F
	.hex 039F03
_moo	.hex 03040451060204500603055007010629; F
	.hex 01270702055207020529012708020529; 1F
	.hex 01280801062802280F04012203280F04; 2F
	.hex 0122032710290227104B030210210207; 3F
	.hex 011002070206163B03040602163B0404; 4F
	.hex 0502163B03041D3B03051D2101060219; 5F
	.hex 1D421A2805191B431E1D020503181818; 6F
	.hex 01070306030F05011302041003040604; 7F
	.hex 0310030406030F03040F04040505030F; 8F
	.hex 040406030E0304100304060502100403; 9F
	.hex 1702041102040704021103031C110303; AF
	.hex 090203102217080203111A0205180604; BF
	.hex 040F1902051A04060210060215351C11; CF
	.hex 030405181C10040208171A100F181910; DF
	.hex 0F181611101715130F1712171011131A; EF
	.hex 080502061B1A040604050801142C1502; FF
	.hex 0411041919120602051116120E11151A; 10F
	.hex 0810122F133012190410090205110D10; 11F
	.hex 0F1511070604031D1C1E1D2612141002; 12F
	.hex 0803061B1223171C1517181915151102; 13F
	.hex 031D12110D0B0D120D0B0E13070F0C0E; 14F
	.hex 0B100C13040D0E0D0C110C110414050A; 15F
	.hex 0F1308090E130A040704051306090602; 16F
	.hex 071306090602070B0303090803140703; 17F
	.hex 06090506020C05040607071210090503; 18F
	.hex 050B0405050A06010714040905050409; 19F
	.hex 0704030C030505090612060306090505; 1AF
	.hex 040906110F0A0604030B060305080704; 1BF
	.hex 030A060405080703040A060404090801; 1CF
	.hex 06090603050907010709050406070703; 1DF
	.hex 06080505050707040509050406070604; 1EF
	.hex 06070605050706040607060505070604; 1FF
	.hex 06070506040805050507060505070506; 20F
	.hex 04070605050705070307070503080605; 21F
	.hex 03080605040706050408050505070506; 22F
	.hex 04080406040902080307041104110510; 23F
	.hex 06110510061006100610060602080507; 24F
	.hex 03060608010706070207060F060F070E; 25F
	.hex 070F070F06100610060F060F060F0610; 26F
	.hex 070E070F070F070F060F070E070F060F; 27F
	.hex 070F060502080610060F060F05060307; 28F
	.hex 06060307050703060508010705080206; 29F
	.hex 05090106060E060F060F060F060F060F; 2AF
	.hex 060F0610060E070E060E070F070D080D; 2BF
	.hex 080E070E070D080D080D080D070E070E; 2CF
	.hex 070D080C070E060F070E070D070D070E; 2DF
	.hex 080D080D070E070D090C070E080D070E; 2EF
	.hex 070E070D080E070D070F070D060F070F; 2FF
	.hex 070D080D070F070E070D080E070E070E; 30F
	.hex 070F060F070E070E070E070F070E070E; 31F
	.hex 070F060F060F070E070F060F060F070F; 32F
	.hex 060F0610050F06100610051005100511; 33F
	.hex 0510061005100511060F060F070F0610; 34F
	.hex 060F070F070F070F0610070F0610070F; 35F
	.hex 070F0710061006100711060F080F0710; 36F
	.hex 0710070F090E090F080F090F0A0D0A0D; 37F
	.hex 0B0D0A0D0B0D0A0E090F091007120613; 38F
	.hex 0A11060F0A11090F07140D0F0D0B0D10; 39F
	.hex 10111114111414161418161A151E171D; 3AF
	.hex 191C1728171D1D2D131B090B131A0C10; 3BF
	.hex 141B02141334161D0D1415351D1F130B; 3CF
	.hex 1D3213141424020F184108150C050316; 3DF
	.hex 0E300F310C200F1A0219091F0F28060D; 3EF
	.hex 074C0B4A111E0428021405250A24053E; 3FF
	.hex 102207FF0F6E04
_quack	.hex 070B070B090A0A0C090D0A080A0A0A0B; 2F
	.hex 090B0B0A070E080A090A08090C0C090B; 3F
	.hex 0D0A0708070905050809080707080508; 4F
	.hex 08090707050707090B1106090707020C; 5F
	.hex 0609030A04060908070A0A090C0A080C; 6F
	.hex 090F070A09090C090C0A0910080A0408; 7F
	.hex 07080308080905060808060708080507; 8F
	.hex 08080307080903050808050209080403; 9F
	.hex 0A070404090F06090406060706040707; AF
	.hex 04050709020307080407060805070309; BF
	.hex 030905070405050703070F0807060307; CF
	.hex 060A0206020503100708060807060303; DF
	.hex 04030407090905040203020303040208; EF
	.hex 03020506010404010304020905030304; FF
	.hex 02050506050506040406030505090408; 10F
	.hex 05050505050604050505050404050405; 11F
	.hex 04050505050405040404050404050405; 12F
	.hex 04050404030404040404050404040404; 13F
	.hex 04030405040504040404040404050404; 14F
	.hex 04040304050407030304050503040404; 15F
	.hex 04030404040404050404040404040404; 16F
	.hex 03040504040604040504040503040404; 17F
	.hex 04040404040504030404040504040404; 18F
	.hex 04040403030403040404040404040404; 19F
	.hex 04040404030404040304040303060506; 1AF
	.hex 04040405030404040507040404040404; 1BF
	.hex 04030404040304040303030402030404; 1CF
	.hex 05040408040405040304040403050404; 1DF
	.hex 04060503050504030404020504040405; 1EF
	.hex 04030204030404040404030803050605; 1FF
	.hex 03030203040404040404030304040404; 20F
	.hex 03040304030404040403030402030304; 21F
	.hex 04070106010304090404090504030403; 22F
	.hex 03030305040304030404040403040304; 23F
	.hex 0404050C030404040302040B05030407; 24F
	.hex 03060604080403050405040403150106; 25F
	.hex 03080204040405050406030504040504; 26F
	.hex 030404040304040403060113030A0404; 27F
	.hex 04040404040503040404040304050204; 28F
	.hex 06050202050403100306021003050505; 29F
	.hex 03050304030503050206040404030504; 2AF
	.hex 04050305011801060305020403080314; 2BF
	.hex 0306020804040503030305070225010F; 2CF
	.hex 020F0205020502100202030404040405; 2DF
	.hex 030E0206010F03060206020502100404; 2EF
	.hex 03050206030403030304060A02050205; 2FF
	.hex 02060107011202050405040403040205; 30F
	.hex 0205030604050304040505040404021F; 31F
	.hex 02050410020603060305030503040204; 32F
	.hex 04030302040304050307010603060118; 33F
	.hex 020D030502070305030802050403050D; 34F
	.hex 03060137040502050205010602060205; 35F
	.hex 03040404030303040405033703040305; 36F
	.hex 031E0308040B01330206010E03190206; 37F
	.hex 010503050104040401630116020A0344; 38F
	.hex 013903050406016F0206028C04040374; 39F
	.hex 02050205030403060242023703060181; 3AF
	.hex 0206037A015E02050386070B060C080A; 3BF
	.hex 030A0813060909090809090B0D080405; 3CF
	.hex 03030509070D060B08080302070D0A07; 3DF
	.hex 060204070A140410020D050502080B04; 3EF
	.hex 060B0403060B0605010702050303030D; 3FF
	.hex 0312040C0A0C0C100A120A0A060A080B; 40F
	.hex 0A0403030809090B090D0108070C090D; 41F
	.hex 090A090A0909070B050708090608090C; 42F
	.hex 090B0709030A090C0A0B0808090B0B09; 43F
	.hex 050602030508070601030B090606090B; 44F
	.hex 0A0C0402040804010304010609020406; 45F
	.hex 06020407020704040303030304060403; 46F
	.hex 02040105030207070404070605040203; 47F
	.hex 04030404050705040404040502020305; 48F
	.hex 04040404040405050505050504050405; 49F
	.hex 04050407040504050405050804050405; 4AF
	.hex 04050404040504050405040504050504; 4BF
	.hex 03050403030504050408050503040406; 4CF
	.hex 05060304040402030403050504050504; 4DF
	.hex 03040504040404040403060303040405; 4EF
	.hex 03040403050404040404040404040404; 4FF
	.hex 04040404040403030304040504040404; 50F
	.hex 04040403050403030404030404040403; 51F
	.hex 04040404040505040302030404040403; 52F
	.hex 04050304040404040404040404040405; 53F
	.hex 04050405040505040404040404040404; 54F
	.hex 03050305040304040404030404040404; 55F
	.hex 04040404040404040404040403040303; 56F
	.hex 04040604030304050403040404040305; 57F
	.hex 03050304020304040404040404040404; 58F
	.hex 04040404040404030404040403040405; 59F
	.hex 03040405030502050304030404040404; 5AF
	.hex 04040404030404040404040404030404; 5BF
	.hex 04040405020403050304030504040404; 5CF
	.hex 04040404030403070302030403050404; 5DF
	.hex 04040405030503050305020701040305; 5EF
	.hex 02040404040503040405030503040204; 5FF
	.hex 04040404040304040404030603040404; 60F
	.hex 04040305030502050305020504050205; 61F
	.hex 040403050A0B02090305030E03050307; 62F
	.hex 020504050204010F0203030503080409; 63F
	.hex 0408030405060205020F020701060205; 64F
	.hex 02050306030503050208040303050704; 65F
	.hex 03060303042B02060205030503060205; 66F
	.hex 03060115040404040305030503050206; 67F
	.hex 02060206021B02070207020701060105; 68F
	.hex 0204030F04060334021D010403040304; 69F
	.hex 040A0204041102090318020601120209; 6AF
	.hex 02050306020502020405030604050305; 6BF
	.hex 023D031202060205020A0403055F020F; 6CF
	.hex 03170105031101080121023101060119; 6DF
	.hex 03050239010F0305030F010803070405; 6EF
	.hex 0271030504040404037E03050404036C; 6FF
	.hex 020603040305016D0106010601050305; 70F
_nomore
