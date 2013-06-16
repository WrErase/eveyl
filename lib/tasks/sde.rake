require 'sde_sqlite_eve'
require 'sde_sqlite_inv'
require 'sde_sqlite_dgm'
require 'sde_sqlite_map'
require 'sde_sqlite_sta'
require 'sde_sqlite_chr'
require 'sde_sqlite_crp'
require 'sde_sqlite_ram'
require 'kconv'

namespace :sde do
  desc "Handle Eve SDE interactions"

  desc "Import SDE data"
  task :import => :environment do
    puts "Loading Units"
    load_units

    puts
    puts "Loading Attribute Types"
    load_attribute_types

    puts
    puts "Loading Type Attributes"
    load_type_attributes

    puts
    puts "Loading Types"
    load_types

    puts
    puts "Loading Type Materials"
    load_type_materials

    puts
    puts "Loading Blueprint Types"
    load_blueprint_types

    puts
    puts "Loading Market Groups"
    load_market_groups

    puts
    puts "Loading Groups"
    load_groups

    puts
    puts "Loading Categories"
    load_categories

    puts
    puts "Loading Meta Types"
    load_meta_types

    puts
    puts "Loading Meta Groups"
    load_meta_groups

    puts
    puts "Loading Flags"
    load_flags

    puts
    puts "Loading Station Types"
    load_station_types

    puts
    puts "Loading Stations"
    load_stations

    puts
    puts "Loading Solar Systems"
    load_systems

    puts
    puts "Loading Constellations"
    load_constellations

    puts
    puts "Loading Regions"
    load_regions

    puts
    puts "Loading Factions"
    load_factions

    puts
    puts "Loading NPC Corporations"
    load_corps

    puts
    puts "Loading Activities"
    load_activities

    puts
    puts "Loading Type Requirements"
    load_type_requirements

    Rails.cache.clear if Rails.cache
  end
end

def load_units
  ActiveRecord::Base.transaction do
    EveUnit.all.each do |eu|
      unit = Unit.find_or_initialize_by_unit_id(eu.unitID)

      unit.update_attributes({:name => eu.unitName,
                              :display_name => eu.displayName,
                              :description => eu.description}, :without_protection => true)
      print '.'
      puts unit.errors unless unit.valid?
    end
  end
end

def load_types
  ActiveRecord::Base.transaction do
    InvType.all.each do |type|
      t = Type.find_or_initialize_by_type_id(type.typeID)
#      unless type.description && type.description.valid_encoding?
#        puts type.typeID
#        puts type.typeName
#        puts type.description
#        puts type.description.unpack("C*").pack("U*") if type.description
#      end

      tech_level = t.attribute_value('techLevel')
      if tech_level
        tech_level = tech_level.to_i

        meta_level = t.attribute_value('metaLevel')
        meta_level = meta_level.to_i unless meta_level.nil?
      end

      t.update_attributes({:group_id => type.groupID,
                           :name => type.typeName,
                           :description => type.description,
                           :mass => type.mass,
                           :volume => type.volume,
                           :capacity => type.capacity,
                           :portion_size => type.portionSize,
                           :race_id => type.raceID,
                           :base_price => type.basePrice,
                           :published => type.published,
                           :market_group_id => type.marketGroupID,
                           :chance_of_duplicating => type.chanceOfDuplicating,
                           :tech_level => tech_level,
                           :meta_level => meta_level}, :without_protection => true)

      print '.'
      puts t.errors unless t.valid?
    end
  end
end

def load_station_types
  ActiveRecord::Base.transaction do
    StaStationTypes.all.each do |type|
      t = StationType.find_or_initialize_by_station_type_id(type.stationTypeID)

      t.update_attributes({:dock_entry_x => type.dockEntryX,
                           :dock_entry_y => type.dockEntryY,
                           :dock_entry_z => type.dockEntryZ,
                           :dock_orientation_x => type.dockOrientationX,
                           :dock_orientation_y => type.dockOrientationY,
                           :dock_orientation_z => type.dockOrientationZ,
                           :operation_id => type.operationID,
                           :office_slots => type.officeSlots,
                           :reprocessing_efficiency => type.reprocessingEfficiency,
                           :conquerable => type.conquerable,
                          }, :without_protection => true)
      print '.'
      puts t.errors unless t.valid?
    end
  end
end

def load_type_materials
  ActiveRecord::Base.transaction do
    InvTypeMaterial.all.each do |mat|
      tm = TypeMaterial.find_or_initialize_by_type_id_and_material_type_id(mat.typeID, mat.materialTypeID)

      tm.update_attributes({:quantity => mat.quantity}, :without_protection => true)

      print '.'
      puts tm.errors unless tm.valid?
    end
  end
end

def load_blueprint_types
  ActiveRecord::Base.transaction do
    InvBlueprintType.all.each do |ibp|
      bp = BlueprintType.find_or_initialize_by_type_id(ibp.blueprintTypeID)

      bp.update_attributes({:product_type_id => ibp.productTypeID,
                            :production_time => ibp.productionTime,
                            :tech_level => ibp.techLevel,
                            :research_productivity_time => ibp.researchProductivityTime,
                            :research_material_time => ibp.researchMaterialTime,
                            :research_copy_time => ibp.researchCopyTime,
                            :research_tech_time => ibp.researchTechTime,
                            :productivity_modifier => ibp.productivityModifier,
                            :material_modifier => ibp.materialModifier,
                            :waste_factor => ibp.wasteFactor,
                            :max_production_limit => ibp.maxProductionLimit}, :without_protection => true)

      print '.'
      puts bp.errors unless bp.valid?
    end
  end
end

def load_type_attributes
  ActiveRecord::Base.transaction do
    DgmTypeAttribute.all.each do |attr|
      typea = TypeAttribute.find_or_initialize_by_type_id_and_attribute_id(attr.typeID, attr.attributeID)

      typea.update_attributes({:type_id => attr.typeID,
                               :attribute_id => attr.attributeID,
                               :value_int => attr.valueInt,
                               :value_float => attr.valueFloat}, :without_protection => true)

      print '.'
      puts typea.errors unless typea.valid?
    end
  end
end

def load_attribute_types
  ActiveRecord::Base.transaction do
    DgmAttributeType.all.each do |attr|
      ta = AttributeType.find_or_initialize_by_attribute_id(attr.attributeID)

      ta.update_attributes({:name => attr.attributeName,
                            :description => attr.description,
                            :icon_id => attr.iconID,
                            :default_value => attr.defaultValue,
                            :published => attr.published,
                            :display_name => attr.displayName,
                            :unit_id => attr.unitID,
                            :stackable => attr.stackable,
                            :high_is_good => attr.highIsGood,
                            :category_id => attr.categoryID}, :without_protection => true)

      print '.'
      puts ta.errors unless ta.valid?
    end
  end
end

def load_categories
  ActiveRecord::Base.transaction do
    InvCategory.all.each do |icat|
      cat = Category.find_or_initialize_by_category_id(icat.categoryID)

      cat.update_attributes({:name => icat.categoryName,
                             :description => icat.description,
                             :icon_id => icat.iconID,
                             :published => icat.published}, :without_protection => true)
      print '.'
      puts cat.errors unless cat.valid?
    end
  end
end

def load_market_groups
  ActiveRecord::Base.transaction do
    InvMarketGroup.all.each do |igrp|
      grp = MarketGroup.find_or_initialize_by_market_group_id(igrp.marketGroupID)

      grp.update_attributes({:name => igrp.marketGroupName,
                             :parent_group_id => igrp.parentGroupID,
                             :description => igrp.description,
                             :icon_id => igrp.iconID,
                             :has_types => igrp.hasTypes}, :without_protection => true)

      print '.'
      puts grp.errors unless grp.valid?
    end
  end
end

def load_groups
  ActiveRecord::Base.transaction do
    InvGroup.all.each do |igrp|
      grp = Group.find_or_initialize_by_group_id(igrp.groupID)

      grp.update_attributes({:name => igrp.groupName,
                             :category_id => igrp.categoryID,
                             :description => igrp.description,
                             :icon_id => igrp.iconID,
                             :use_base_price => igrp.useBasePrice,
                             :allow_manufacture => igrp.allowManufacture,
                             :allow_recycler => igrp.allowRecycler,
                             :anchored => igrp.anchored,
                             :anchorable => igrp.anchorable,
                             :fittable_non_singleton => igrp.fittableNonSingleton,
                             :published => igrp.published}, :without_protection => true)
      print '.'
      puts grp.errors unless grp.valid?
    end
  end
end

def load_meta_types
  ActiveRecord::Base.transaction do
    InvMetaType.all.each do |imt|
      mt = MetaType.find_or_initialize_by_type_id(imt.typeID)

      mt.update_attributes({:type_id => imt.typeID,
                            :parent_type_id => imt.parentTypeID,
                            :meta_group_id => imt.metaGroupID}, :without_protection => true)
      print '.'
      puts mt.errors unless mt.valid?
    end
  end
end

def load_meta_groups
  ActiveRecord::Base.transaction do
    InvMetaGroup.all.each do |img|
      mg = MetaGroup.find_or_initialize_by_meta_group_id(img.metaGroupID)

      mg.update_attributes({:meta_group_id => img.metaGroupID,
                            :name => img.metaGroupName,
                            :description => img.description,
                            :icon_id => img.iconID}, :without_protection => true)
      print '.'
      puts mg.errors unless mg.valid?
    end
  end
end

def load_flags
  ActiveRecord::Base.transaction do
    InvFlag.all.each do |iflag|
      flag = Flag.find_or_initialize_by_flag_id(iflag.flagID)

      flag.update_attributes({:name => iflag.flagName,
                              :text => iflag.flagText}, :without_protection => true)
      print '.'
      puts flag.errors unless flag.valid?
    end
  end
end

def load_stations
  ActiveRecord::Base.transaction do
    StaStations.all.each do |sta|
      station = Station.find_or_initialize_by_station_id(sta.stationID)

      station.update_attributes({:name => sta.stationName,
                                 :station_type_id => sta.stationTypeID,
                                 :corporation_id => sta.corporationID,
                                 :solar_system_id => sta.solarSystemID,
                                 :constellation_id => sta.constellationID,
                                 :region_id => sta.regionID,
                                 :reprocess_eff => sta.reprocessingEfficiency,
                                 :reprocess_take => sta.reprocessingStationsTake}, :without_protection => true)
      print '.'
      puts station.errors unless station.valid?
    end
  end
end

def load_systems
  ActiveRecord::Base.transaction do
    MapSolarSystem.all.each do |sys|
      system = SolarSystem.find_or_initialize_by_solar_system_id(sys.solarSystemID)

      system.update_attributes({:name => sys.solarSystemName,
                                :security => sys.security,
                                :security_class => sys.securityClass,
                                :constellation_id => sys.constellationID,
                                :region_id => sys.regionID,
#                                :faction_id => sys.factionID,
                                :border => sys.border,
                                :fringe => sys.fringe,
                                :corridor => sys.corridor,
                                :hub => sys.hub,
                                :international => sys.international,
                                :regional => sys.regional,
                                :constellational => sys.constellation}, :without_protection => true)
      print '.'
      puts system.errors unless system.valid?
    end
  end
end

def load_constellations
  ActiveRecord::Base.transaction do
    MapConstellation.all.each do |c|
      const = Constellation.find_or_initialize_by_constellation_id(c.constellationID)

      const.update_attributes({:name => c.constellationName,
                               :region_id => c.regionID,
                               :faction_id => c.factionID}, :without_protection => true)
      print '.'
      puts const.errors unless const.valid?
    end
  end
end

def load_regions
  ActiveRecord::Base.transaction do
    MapRegion.all.each do |r|
      region = Region.find_or_initialize_by_region_id(r.regionID)

      region.update_attributes({:name => r.regionName,
                                :faction_id => r.factionID}, :without_protection => true)
      print '.'
      puts region.errors unless region.valid?
    end
  end
end

def load_factions
  ActiveRecord::Base.transaction do
    ChrFactions.all.each do |f|
      faction = Faction.find_or_initialize_by_faction_id(f.factionID)

      faction.update_attributes({name: f.factionName,
                                description: f.description,
                                solar_system_id: f.solarSystemID,
                                corporation_id: f.corporationID,
                                station_count: f.stationCount,
                                station_system_count: f.stationSystemCount,
                                militia_corporation_id: f.militiaCorporationID,
                                icon_id: f.iconID}, without_protection: true)
      print '.'
      puts faction.errors unless faction.valid?
    end
  end
end

def load_corps
  ActiveRecord::Base.transaction do
    CrpNPCCorporations.all.each do |c|
      corp = Corporation.find_or_initialize_by_corporation_id(c.corporationID)
      corp.description = c.description
      corp.npc = true

      corp.name = InvName.find(c.corporationID).itemName
      puts corp.inspect
      corp.save

      print '.'
      puts corp.errors unless corp.valid?
    end
  end
end

def load_activities
  ActiveRecord::Base.transaction do
    RamActivities.all.each do |a|
      act = Activity.find_or_initialize_by_activity_id(a.activityID)

      act.name = a.activityName
      act.icon_no = a.iconNo
      act.description = a.description
      act.published = a.published == 1
      act.save

      print '.'
      puts act.errors unless act.valid?
    end
  end
end

def load_type_requirements
  ActiveRecord::Base.transaction do
    RamTypeRequirements.all.each do |r|
      req = TypeRequirement.where(type_id: r.typeID,
                                  activity_id: r.activityID,
                                  required_type_id: r.requiredTypeID).first

      req = TypeRequirement.new unless req
      req.update_attributes({type_id: r.typeID,
                             activity_id: r.activityID,
                             required_type_id: r.requiredTypeID,
                             quantity: r.quantity,
                             damage_per_job: r.damagePerJob,
                             recycle: r.recycle == 1},
                            without_protection: true)

      print '.'
      puts req.errors unless req.valid?
    end
  end
end
