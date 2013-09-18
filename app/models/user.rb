class User
  include Mongoid::Document
  include Mongoid::Timestamps

	# Add call to strip leading and trailing white spaces from all atributes
	strip_attributes  # See strip_attributes for more information
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable
  
  ## Database authenticatable
  field :email,              :type => String, :default => ""
  field :encrypted_password, :type => String, :default => ""
  
  ## Recoverable
  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Trackable
  field :sign_in_count,      :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip,    :type => String

  ## Confirmable
  # field :confirmation_token,   :type => String
  # field :confirmed_at,         :type => Time
  # field :confirmation_sent_at, :type => Time
  # field :unconfirmed_email,    :type => String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, :type => Integer, :default => 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    :type => String # Only if unlock strategy is :email or :both
  # field :locked_at,       :type => Time

  ## Token authenticatable
  field :authentication_token, :type => String
 
  ## CONSTANTS ----------------------------------------------------------

  # CUSTOMER ROLE - constant for specifying a customer role
  CUSTOMER = 1

  # SERVICE_ADMIN - constant for specify a service administrator
  SERVICE_ADMIN = 2
 
  ## Additional fields and validations ---------------------------------
  field :first_name, type: String, default: ''
  validates_presence_of :first_name
  
  field :last_name, type: String, default: ''
  validates_presence_of :last_name
  
  field :phone, type: String, default: ''
  validates_presence_of :phone
  
  validates :email, presence: true, uniqueness: true
  
  field :role, type: Integer, default: CUSTOMER
  validates :role, inclusion: { in: [CUSTOMER, SERVICE_ADMIN],
    message: "User has an invalid role." }
  
  ## Relationship items ------------------------------------------------
  has_and_belongs_to_many :groups, dependent: :destroy
  
  ## INSTANCE METHODS --------------------------------------------------
  
  ######################################################################
  # The role_str returns the string representation of the role assigned
  # to the user.
  ######################################################################
  def role_str
  	case self.role
		when CUSTOMER
			"Customer"
		when SERVICE_ADMIN
			"Service Administrator"
		else
			"Unknown"
		end
  end
  
end

