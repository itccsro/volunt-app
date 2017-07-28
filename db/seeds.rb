# Seed database depending on the environment:
case Rails.env
when "development"
  # env == "development":
  profile1 = Profile.create!(:full_name => "John Doe", :nick_name => "johndoe", :email => "johndoe@civictech.ro",
                             :flags => 0xF) # (0x1 | 0x2 | 0x4 | 0x8; all flags)
  profile2 = Profile.create!(:full_name => "Coordinator", :nick_name => "coordinator",
                             :email => "coordinator@civictech.ro", :flags => 0x8)
  profile3 = Profile.create!(:full_name => "Fellow", :nick_name => "fellow", :email => "fellow@civictech.ro",
                             :flags => 0x4)
  profile4 = Profile.create!(:full_name => "Volunteer", :nick_name => "volunteer", :email => "volunteer@civictech.ro",
                             :flags => 0x2)
  profile5 = Profile.create!(:full_name => "Applicant", :nick_name => "applicant", :email => "applicant@civictech.ro",
                             :flags => 0x1)
  
  User.create(:email => profile1.email, :password => "fKL9UeKSkH4CtA")
  User.create(:email => profile2.email, :password => "91WjtWiNA6BjhQ")
  User.create(:email => profile3.email, :password => "tsU3kZlnawTJ2Q")
  User.create(:email => profile4.email, :password => "90s7hD23vrjvKw")
  User.create(:email => profile5.email, :password => "m9dZmxPQfAsv8w")
end
