//
// Created by vastrakai on 10/8/2024.
//

#include "InventoryLib.hpp"

#include <SDK/Minecraft/Inventory/PlayerInventory.hpp>

void InventoryLib::initialize(lua_State* L)
{
    getGlobalNamespace(L)
        .beginClass<PlayerInventory>("PlayerInventory")
            .addFunction("getContainer", &PlayerInventory::getContainer)
            .addProperty("mSelectedSlot", [](PlayerInventory* self) { return self->mSelectedSlot; }, [](PlayerInventory* self, int value) { self->mSelectedSlot = value; })
            .addProperty("mInHandSlot", [](PlayerInventory* self) { return self->mInHandSlot; }, [](PlayerInventory* self, int value) { self->mInHandSlot = value; })
        .endClass()
        .beginClass<Inventory>("Inventory")
            .addFunction("dropSlot", &Inventory::dropSlot)
            .addFunction("swapSlots", &Inventory::swapSlots)
            .addFunction("equipArmor", &Inventory::equipArmor)
            .addFunction("startUsingItem", &Inventory::startUsingItem)
            .addFunction("releaseUsingItem", &Inventory::releaseUsingItem)
            .addFunction("getItem", &SimpleContainer::getItem)
            .addFunction("setItem", &SimpleContainer::setItem)
        .endClass()
        .beginClass<SimpleContainer>("SimpleContainer")
            .addFunction("getItem", &SimpleContainer::getItem)
            .addFunction("setItem", &SimpleContainer::setItem)
        .endClass()
        .beginClass<ItemStack>("ItemStack")
            .addFunction("getCustomName", &ItemStack::getCustomName)
            .addFunction("getEnchantValue", [](ItemStack* self, int id) { return self->getEnchantValue(id); })
            .addFunction("hasItem", [](ItemStack* self) { return self->mItem != nullptr; })
            .addFunction("getItem", &ItemStack::getItem)
            .addProperty("mStackNetId", &ItemStack::mStackNetId)
            .addProperty("mCompoundTag", &ItemStack::mCompoundTag)
            .addProperty("mBlock", &ItemStack::mBlock)
            .addProperty("mAuxValue", &ItemStack::mAuxValue)
            .addProperty("mCount", &ItemStack::mCount)
            .addProperty("valid", &ItemStack::valid)
            .addConstructor<void (*)()>()
            .addConstructor<void (*)(Item*, int, int)>()
        .endClass()
        .beginClass<Item>("Item")
            .addProperty("mItemId", [](Item* self) { return self->mItemId; }, [](Item* self, short value) { self->mItemId = value; })
            .addProperty("mArmorItemType", [](Item* self) { return self->mArmorItemType; }, [](Item* self, int value) { self->mArmorItemType = value; })
            .addProperty("mProtection", [](Item* self) { return self->mProtection; }, [](Item* self, int value) { self->mProtection = value; })
            .addProperty("mName", [](Item* self) { return self->mName; }, [](Item* self, std::string value) { self->mName = value; })
            .addFunction("getArmorSlot", &Item::getArmorSlot)
            .addFunction("isHelmet", &Item::isHelmet)
            .addFunction("isChestplate", &Item::isChestplate)
            .addFunction("isLeggings", &Item::isLeggings)
            .addFunction("isBoots", &Item::isBoots)
            .addFunction("isSword", &Item::isSword)
            .addFunction("isPickaxe", &Item::isPickaxe)
            .addFunction("isAxe", &Item::isAxe)
            .addFunction("isShovel", &Item::isShovel)
            .addFunction("getItemTier", &Item::getItemTier)
            .addFunction("getItemType", &Item::getItemType)
        .endClass()
    ;
}
