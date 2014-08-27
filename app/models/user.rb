  class User < ActiveRecord::Base
    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable, :trackable, :validatable

    has_many :todos
    has_many :roles, :through => :user_roles

    before_create :setup_default_role_for_new_users

    ROLES = %w[admin user]

    def role_symbols
      [role.to_sym]
    end

    def roles=(roles)
      self.roles_mask = (roles & ROLES).map { |r| 2**ROLES.index(r) }.inject(0, :+)
    end

    def roles
      ROLES.reject do |r|
        ((roles_mask.to_i || 0) & 2**ROLES.index(r)).zero?
      end
    end

    def role?(role) 
      roles.include?(role.to_s)
    end

    def setup_default_role_for_new_users
      if self.role.blank?
        self.role = "user"
      end
    end
  end
