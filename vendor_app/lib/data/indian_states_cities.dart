/// Indian States and their Cities data for registration forms
class IndianStatesData {
  /// All 28 states + 8 Union Territories
  static const List<String> states = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
    // Union Territories
    'Andaman and Nicobar Islands',
    'Chandigarh',
    'Dadra and Nagar Haveli and Daman and Diu',
    'Delhi',
    'Jammu and Kashmir',
    'Ladakh',
    'Lakshadweep',
    'Puducherry',
  ];

  /// Cities mapped to their states
  static const Map<String, List<String>> citiesByState = {
    'Andhra Pradesh': [
      'Visakhapatnam', 'Vijayawada', 'Guntur', 'Nellore', 'Kurnool',
      'Tirupati', 'Rajahmundry', 'Kakinada', 'Kadapa', 'Anantapur',
      'Eluru', 'Ongole', 'Chittoor', 'Machilipatnam', 'Srikakulam',
      'Tenali', 'Proddatur', 'Adoni', 'Hindupur', 'Bhimavaram',
    ],
    'Arunachal Pradesh': [
      'Itanagar', 'Naharlagun', 'Pasighat', 'Tawang', 'Ziro',
      'Bomdila', 'Along', 'Tezu', 'Roing', 'Daporijo',
      'Namsai', 'Changlang', 'Khonsa', 'Yingkiong', 'Anini',
    ],
    'Assam': [
      'Guwahati', 'Silchar', 'Dibrugarh', 'Jorhat', 'Nagaon',
      'Tinsukia', 'Tezpur', 'Bongaigaon', 'Karimganj', 'Goalpara',
      'Dhubri', 'North Lakhimpur', 'Sibsagar', 'Diphu', 'Barpeta',
      'Golaghat', 'Haflong', 'Mangaldoi', 'Nalbari', 'Rangia',
    ],
    'Bihar': [
      'Patna', 'Gaya', 'Bhagalpur', 'Muzaffarpur', 'Purnia',
      'Darbhanga', 'Bihar Sharif', 'Arrah', 'Begusarai', 'Katihar',
      'Munger', 'Chhapra', 'Saharsa', 'Sasaram', 'Hajipur',
      'Dehri', 'Siwan', 'Motihari', 'Nawada', 'Bettiah',
    ],
    'Chhattisgarh': [
      'Raipur', 'Bhilai', 'Bilaspur', 'Korba', 'Durg',
      'Rajnandgaon', 'Jagdalpur', 'Ambikapur', 'Raigarh', 'Dhamtari',
      'Mahasamund', 'Kawardha', 'Kanker', 'Janjgir', 'Chirmiri',
    ],
    'Goa': [
      'Panaji', 'Margao', 'Vasco da Gama', 'Mapusa', 'Ponda',
      'Bicholim', 'Canacona', 'Curchorem', 'Sanquelim', 'Quepem',
      'Sanguem', 'Pernem', 'Cuncolim', 'Cortalim', 'Aldona',
    ],
    'Gujarat': [
      'Ahmedabad', 'Surat', 'Vadodara', 'Rajkot', 'Bhavnagar',
      'Jamnagar', 'Junagadh', 'Gandhinagar', 'Anand', 'Nadiad',
      'Morbi', 'Mehsana', 'Bharuch', 'Navsari', 'Vapi',
      'Surendranagar', 'Porbandar', 'Godhra', 'Veraval', 'Palanpur',
    ],
    'Haryana': [
      'Gurugram', 'Faridabad', 'Panipat', 'Ambala', 'Karnal',
      'Rohtak', 'Hisar', 'Sonipat', 'Yamunanagar', 'Panchkula',
      'Bhiwani', 'Sirsa', 'Rewari', 'Jind', 'Kurukshetra',
      'Kaithal', 'Bahadurgarh', 'Thanesar', 'Palwal', 'Mahendragarh',
    ],
    'Himachal Pradesh': [
      'Shimla', 'Dharamshala', 'Mandi', 'Solan', 'Kullu',
      'Manali', 'Bilaspur', 'Hamirpur', 'Una', 'Palampur',
      'Nahan', 'Chamba', 'Kangra', 'Sundernagar', 'Keylong',
    ],
    'Jharkhand': [
      'Ranchi', 'Jamshedpur', 'Dhanbad', 'Bokaro', 'Deoghar',
      'Hazaribagh', 'Giridih', 'Ramgarh', 'Phusro', 'Medininagar',
      'Dumka', 'Chaibasa', 'Chatra', 'Lohardaga', 'Gumla',
    ],
    'Karnataka': [
      'Bengaluru', 'Mysuru', 'Hubli-Dharwad', 'Mangaluru', 'Belagavi',
      'Kalaburagi', 'Davanagere', 'Ballari', 'Shivamogga', 'Tumakuru',
      'Udupi', 'Raichur', 'Bidar', 'Hassan', 'Mandya',
      'Chitradurga', 'Gadag', 'Bagalkot', 'Haveri', 'Chikkamagaluru',
    ],
    'Kerala': [
      'Thiruvananthapuram', 'Kochi', 'Kozhikode', 'Thrissur', 'Kollam',
      'Palakkad', 'Alappuzha', 'Kannur', 'Kottayam', 'Malappuram',
      'Kasaragod', 'Pathanamthitta', 'Idukki', 'Wayanad', 'Munnar',
      'Thodupuzha', 'Attingal', 'Kayamkulam', 'Perinthalmanna', 'Guruvayoor',
    ],
    'Madhya Pradesh': [
      'Bhopal', 'Indore', 'Jabalpur', 'Gwalior', 'Ujjain',
      'Sagar', 'Dewas', 'Satna', 'Ratlam', 'Rewa',
      'Katni', 'Singrauli', 'Burhanpur', 'Khandwa', 'Chhindwara',
      'Morena', 'Bhind', 'Shivpuri', 'Vidisha', 'Damoh',
    ],
    'Maharashtra': [
      'Mumbai', 'Pune', 'Nagpur', 'Thane', 'Nashik',
      'Aurangabad', 'Solapur', 'Kolhapur', 'Amravati', 'Navi Mumbai',
      'Sangli', 'Jalgaon', 'Akola', 'Latur', 'Dhule',
      'Ahmednagar', 'Chandrapur', 'Parbhani', 'Satara', 'Nanded',
      'Ichalkaranji', 'Ratnagiri', 'Osmanabad', 'Wardha', 'Gondia',
    ],
    'Manipur': [
      'Imphal', 'Thoubal', 'Bishnupur', 'Churachandpur', 'Kakching',
      'Senapati', 'Ukhrul', 'Chandel', 'Tamenglong', 'Jiribam',
      'Moreh', 'Moirang', 'Lilong', 'Mayang Imphal', 'Nambol',
    ],
    'Meghalaya': [
      'Shillong', 'Tura', 'Jowai', 'Nongstoin', 'Williamnagar',
      'Baghmara', 'Resubelpara', 'Nongpoh', 'Mairang', 'Khliehriat',
      'Cherrapunji', 'Mawkyrwat', 'Ampati', 'Dawki', 'Nongthymmai',
    ],
    'Mizoram': [
      'Aizawl', 'Lunglei', 'Champhai', 'Serchhip', 'Kolasib',
      'Lawngtlai', 'Saiha', 'Mamit', 'Saitual', 'Khawzawl',
      'Hnahthial', 'Bairabi', 'Tlabung', 'Thenzawl', 'North Vanlaiphai',
    ],
    'Nagaland': [
      'Kohima', 'Dimapur', 'Mokokchung', 'Tuensang', 'Wokha',
      'Zunheboto', 'Mon', 'Phek', 'Kiphire', 'Longleng',
      'Peren', 'Pfutsero', 'Chumukedima', 'Tuli', 'Jalukie',
    ],
    'Odisha': [
      'Bhubaneswar', 'Cuttack', 'Rourkela', 'Berhampur', 'Sambalpur',
      'Puri', 'Balasore', 'Bhadrak', 'Baripada', 'Jharsuguda',
      'Jeypore', 'Angul', 'Dhenkanal', 'Bargarh', 'Paradip',
      'Kendujhar', 'Koraput', 'Rayagada', 'Phulbani', 'Sundargarh',
    ],
    'Punjab': [
      'Ludhiana', 'Amritsar', 'Jalandhar', 'Patiala', 'Bathinda',
      'Mohali', 'Pathankot', 'Hoshiarpur', 'Batala', 'Moga',
      'Abohar', 'Malerkotla', 'Khanna', 'Phagwara', 'Muktsar',
      'Barnala', 'Rajpura', 'Firozpur', 'Kapurthala', 'Sangrur',
    ],
    'Rajasthan': [
      'Jaipur', 'Jodhpur', 'Udaipur', 'Kota', 'Bikaner',
      'Ajmer', 'Bhilwara', 'Alwar', 'Sikar', 'Bharatpur',
      'Pali', 'Sri Ganganagar', 'Kishangarh', 'Tonk', 'Beawar',
      'Hanumangarh', 'Chittorgarh', 'Jhunjhunu', 'Nagaur', 'Bundi',
    ],
    'Sikkim': [
      'Gangtok', 'Namchi', 'Gyalshing', 'Mangan', 'Rangpo',
      'Singtam', 'Jorethang', 'Ravangla', 'Pelling', 'Lachung',
      'Yuksom', 'Naya Bazar', 'Soreng', 'Rhenock', 'Pakyong',
    ],
    'Tamil Nadu': [
      'Chennai', 'Coimbatore', 'Madurai', 'Tiruchirappalli', 'Salem',
      'Tirunelveli', 'Erode', 'Vellore', 'Thoothukudi', 'Dindigul',
      'Thanjavur', 'Tiruppur', 'Ranipet', 'Nagercoil', 'Kanchipuram',
      'Cuddalore', 'Karur', 'Sivakasi', 'Kumbakonam', 'Hosur',
    ],
    'Telangana': [
      'Hyderabad', 'Warangal', 'Nizamabad', 'Karimnagar', 'Khammam',
      'Ramagundam', 'Mahbubnagar', 'Nalgonda', 'Adilabad', 'Suryapet',
      'Siddipet', 'Miryalaguda', 'Mancherial', 'Kamareddy', 'Bhongir',
      'Jagtial', 'Medak', 'Wanaparthy', 'Kothagudem', 'Bodhan',
    ],
    'Tripura': [
      'Agartala', 'Udaipur', 'Dharmanagar', 'Kailashahar', 'Belonia',
      'Ambassa', 'Khowai', 'Sabroom', 'Sonamura', 'Bishramganj',
      'Kamalpur', 'Amarpur', 'Teliamura', 'Kumarghat', 'Santirbazar',
    ],
    'Uttar Pradesh': [
      'Lucknow', 'Kanpur', 'Agra', 'Varanasi', 'Meerut',
      'Prayagraj', 'Ghaziabad', 'Noida', 'Bareilly', 'Aligarh',
      'Moradabad', 'Gorakhpur', 'Saharanpur', 'Jhansi', 'Firozabad',
      'Mathura', 'Muzaffarnagar', 'Shahjahanpur', 'Rampur', 'Ayodhya',
      'Sultanpur', 'Faizabad', 'Etawah', 'Mirzapur', 'Bijnor',
    ],
    'Uttarakhand': [
      'Dehradun', 'Haridwar', 'Rishikesh', 'Haldwani', 'Roorkee',
      'Kashipur', 'Rudrapur', 'Nainital', 'Mussoorie', 'Pithoragarh',
      'Almora', 'Kotdwar', 'Srinagar', 'Ramnagar', 'Bageshwar',
      'Champawat', 'Tehri', 'Pauri', 'Uttarkashi', 'Lansdowne',
    ],
    'West Bengal': [
      'Kolkata', 'Howrah', 'Durgapur', 'Asansol', 'Siliguri',
      'Bardhaman', 'Malda', 'Baharampur', 'Habra', 'Kharagpur',
      'Haldia', 'Darjeeling', 'Krishnanagar', 'Jalpaiguri', 'Raiganj',
      'Balurghat', 'Cooch Behar', 'Bankura', 'Purulia', 'Medinipur',
    ],
    // Union Territories
    'Andaman and Nicobar Islands': [
      'Port Blair', 'Diglipur', 'Rangat', 'Mayabunder', 'Hut Bay',
      'Car Nicobar', 'Bamboo Flat', 'Garacharma', 'Prothrapur', 'Wimberlygunj',
    ],
    'Chandigarh': [
      'Chandigarh', 'Manimajra', 'Burail', 'Maloya', 'Dhanas',
    ],
    'Dadra and Nagar Haveli and Daman and Diu': [
      'Silvassa', 'Daman', 'Diu', 'Amli', 'Naroli',
    ],
    'Delhi': [
      'New Delhi', 'Central Delhi', 'North Delhi', 'South Delhi',
      'East Delhi', 'West Delhi', 'North East Delhi', 'North West Delhi',
      'South East Delhi', 'South West Delhi', 'Shahdara', 'Dwarka',
      'Rohini', 'Saket', 'Lajpat Nagar', 'Karol Bagh', 'Connaught Place',
      'Janakpuri', 'Pitampura', 'Vasant Kunj',
    ],
    'Jammu and Kashmir': [
      'Srinagar', 'Jammu', 'Anantnag', 'Baramulla', 'Sopore',
      'Kathua', 'Udhampur', 'Pulwama', 'Kupwara', 'Rajouri',
      'Poonch', 'Doda', 'Kishtwar', 'Kulgam', 'Bandipora',
    ],
    'Ladakh': [
      'Leh', 'Kargil', 'Diskit', 'Padum', 'Nyoma',
    ],
    'Lakshadweep': [
      'Kavaratti', 'Agatti', 'Minicoy', 'Andrott', 'Amini',
    ],
    'Puducherry': [
      'Puducherry', 'Karaikal', 'Mahe', 'Yanam', 'Ozhukarai',
      'Villianur', 'Ariyankuppam', 'Bahour', 'Lawspet', 'Mudaliarpet',
    ],
  };

  /// Get cities for a given state
  static List<String> getCitiesForState(String state) {
    return citiesByState[state] ?? [];
  }
}
