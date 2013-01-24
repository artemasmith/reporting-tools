#!/bin/env ruby
#encoding: utf-8

class Repissue < ActiveRecord::Base

#return performer name by id
def self.find_name_by_id(v)
    if !v.blank?
        us=User.find_by_id(v)        
        usname=""
        if us.blank?
            us=Group.find_by_id(v)     
     usname=us.lastname
     #path="a"
        else            
            usname=us.firstname + " " + us.lastname            
        end
    else
	return "Нет исполнителя"
    end
    res=usname
    
end

#check should we return task by our conditions when we need exceeded tasks or soon-closed tasks
def self.check_to_save(mode,period,end_date)
	delta=end_date.to_date - Date.today
	case mode
		when "exceed"
			if delta.to_i<0 and  end_date.to_date>= get_start_date(period)
				return true
			end
		when "soon"
			if delta >0 and delta.abs.ceil <= 3
				return true
			end
	end
	return false
end

def self.get_start_date(period)
	start_day=(Date.today-period).beginning_of_month
end

#return all exxeded and soon ended issues
#mode - determine which issues we return
#:exceed-we return exceeded issues
#soon-we return only soon ended tasks
#all-we return all tasks
def self.all(mode, period = 7)
    
    issues=Issue.find(:all, :conditions => ["status_id < 9"])
    issues.concat(Issue.find(:all, :conditions => ["status_id > 11"]))

    s=[]
    @resissues=[]
    j=0

    issues.each do |issue|
        k=0
        #i cant push this code in methods
        #here we get custom_fields of issue
        if !issue.custom_field_values.empty?
            value = issue.custom_field_values
            for i in 0..value.size-1
                if !value[i].blank?
                    s[k]=value[i].to_s
                    k+=1
                end
            end
        end

        #here we compare custom values dates to current date
        	
        temp={}
        delta=(s[0].to_s.to_date - Date.today)
        
        if  check_to_save(mode,period,s[0].to_s)
            temp[:id]=issue[:id]
            temp[:subject]=issue[:subject].to_s + '-|-' + issue[:id].to_s
            temp[:assigned_to_id]= find_name_by_id(issue[:assigned_to_id]).to_s+ '-' + issue[:assigned_to_id].to_s
            temp[:project_id]= Project.find_by_id(issue[:project_id]).to_s + '-' + issue[:project_id].to_s
            temp[:done_ratio]=issue[:done_ratio]
            temp[:start_date]=issue[:start_date]
            temp[:deadend] = s[0].to_s
            temp[:delayed_days]=delta.to_i.abs
            @resissues[j]=temp
            j+=1
        end
        
    end
    return @resissues
    
end


end