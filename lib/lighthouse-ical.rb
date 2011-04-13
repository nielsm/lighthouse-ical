require 'lighthouse-api'
require 'icalendar'

class LighthouseIcal

  #Returns an ics formatted string of all the milestones in the project
  def self.create_calendar_for_project_id(project_id)
    project = Lighthouse::Project.find(project_id)
    calendar = Icalendar::Calendar.new
    milestones = scheduled_milestones_in_project(project_id)
    milestones.each do |ms|
      # Retrieve the due_on value for each milestone & stip the time component
      #Retrieve the title of the milestone & set it to the summary
      #Retrieve the goals of the milestone & set it to the description
      calendar.event do
        dtstart       ms.due_on.to_date
        dtend         ms.due_on.to_date
        summary     ms.title
        description ms.goals
      end
    end
    calendar.publish
    return calendar.to_ical
  end

  #Generates an ics file at the specified filepath of available milestones for the selected project
  def self.create_ics_file_for_project_id(filepath,project_id)
    file = File.new(filepath,"w+")
    file.write(self.create_calendar_for_project_id(project_id))
    file.close
  end

  private 

  #FIXME This is a hack to work around Lighthouse API only providing 30 milestones at a time.
  #This is not performant & could result in N API calls where N is the number of pages of milestones
  def self.milestones_in_project(project_id)
    project = Lighthouse::Project.find(project_id)
    all_milestones = []
    i = 1 
    milestones = project.milestones(:page => i) 
    while (milestones.any?) do 
      i += 1 
      all_milestones << milestones 
      milestones = project.milestones(:page => i)
    end
    return all_milestones
  end

  def self.scheduled_milestones_in_project(project_id)
    raw_milestones = self.milestones_in_project(project_id)
    scheduled = raw_milestones.select{|milestone|!milestone.due_on.blank?}.sort!{|a,b|a.due_on <=> b.due_on}
  end


end